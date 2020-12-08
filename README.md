# README

This pair programming task is designed to test your ability to jump into an unfamiliar codebase and diagnose a support issue.

This is based on a real example of a support request with some of the details slightly simplified.

The ticket we received from the customer was:

```text
Hey Arcade,

We recently added 4 new users to our account and only one of them is correctly creating sales. 
Can you look into why this is happening and ensure that each of our users is showing 2 sales within the platform?

Thanks,

John Smith
```

As the ticket mentions your goal is to ensure that each of the 4 users correctly has 2 sales in the platform!

But first we need to get the codebase setup.

### Setup

After cloning the repo to your local machine you will need to install the required gems using:
```bash
$ bundle install
```

Then you can create your local database using:
```bash
$ rake db:create
```
(This depends on you having a local instance of Postgres running that is listening on localhost and accessible by a user with your system username. You can tweak the database.yml as necessary)

Once the database has been created you can create the necessary tables using:
```bash
$ rake db:schema:load
```

And finally populate the database using:
```bash
$ rake db:seed
```

### Testing
You have access to a rake task that will output how many sales each user in the company has. You can run this using:
```bash
$ rake check_sales
```

If you run this initially you should see this output:

```text
If you are successful then each of these users should have two sales
User: James McLaren Sale Count: 2
User: David Parry Sale Count: 0
User: Odisha Odicho Sale Count: 0
User: Sharon Chen Sale Count: 0
```

You can run this rake task as many times as you like throughout the process to check your progress.

### Hints
There are two files in the codebase that may give you insight into what the problem (or problems) is. These are:
* `db/seeds.rb`
* `app/lib/iq_metrix/performance_group.rb`

If you are completely stuck you're more than welcome to check these out but be sure to ask your pair programming partner first as they may be able to help you