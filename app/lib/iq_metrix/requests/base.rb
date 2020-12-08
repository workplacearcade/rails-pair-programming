# frozen_string_literal: true

module IQMetrix
  module Requests
    class Base
      def make_web_request(request_object)
        request = construct_typhoeus_request(request_object)

        handle_response_code request.run, request_object
      end

      def headerless_web_request(request_object)
        make_web_request request_object
      end

      def web_request(request_object)
        make_web_request request_object.merge(
          headers: default_headers.merge(request_object[:headers] || {})
        )
      end

      def authenticated_web_request(request_object)
        make_web_request generate_authenticated_web_request_object(request_object)
      end

      private

      def construct_typhoeus_request(request_object)
        Typhoeus::Request.new(
          request_object[:url],
          **request_object.slice(:method, :params, :body, :headers, :method)
        )
      end

      def generate_authenticated_web_request_object(request_object)
        request_object.merge(
          headers: authenticated_headers.merge(request_object[:headers] || {})
        )
      end

      def handle_response_code(response, request_object, retrying: false)
        case response.code
        when 200
          JSON.parse(response.response_body)
        when 401
          raise IQMetrix::Errors::AuthenticationError, response.response_body if retrying

          IQMetrix::AuthenticationToken.refresh_token

          request_object = generate_authenticated_web_request_object(request_object.except(:headers))
          request = construct_typhoeus_request(request_object)

          handle_response_code(request.run, request_object, retrying: true)
        when 500
          raise IQMetrix::Errors::ServerError, response.response_body
        else
          raise IQMetrix::Errors::UnknownError, response.response_body
        end
      end

      def authenticated_headers
        default_headers.merge(Authorization: "Bearer #{token}")
      end

      def default_headers
        {
          Accept: 'application/JSON',
          'Content-Type' => 'application/JSON'
        }
      end

      def token
        IQMetrix::AuthenticationToken.get
      end
    end
  end
end
