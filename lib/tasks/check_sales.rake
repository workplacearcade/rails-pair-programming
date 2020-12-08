desc "Run the sales processing task and see how many matches we have"
task check_sales: :environment do
  performance_group = IQMetrix::PerformanceGroup.first

  IQMetrix::Arcade::GetSalesForPerformanceGroup.run(
    performance_group: performance_group
  )

  puts "If you are successful then each of these users should have two sales"

  User.find_each do |user|
    puts "User: #{user.name} Sale Count: #{user.sales.size}"
  end

  puts "\n\nNice work!" if Sale.count == User.count * 2
end