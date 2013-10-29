# Backsum

backsum is unix base the file system backup tools, it will incremental backup remote file to local storage.

## Installation

Add this line to your application's Gemfile:

    gem 'backsum'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backsum

## Usage

First, you have to configure your backup tasks.

    $ mkdir ./projects
    $ vi ./projects/one_task.rb

Create a ruby file to configure your first task.

    # one_task.rb
    
    name "one_task_name"
    
    server "remotehost", username: "www-data" do
      folder "/var/www/demo/apps/one_web/shared"
      folder "/var/www/demo/apps/two_web/shared", excluded: ["logs", "assets"], as: "two_web_backup"
    end
    
    server "localhost", local: true do
      folder "/foo", excluded: ["bar"], as: "local_backup"
    end

Here’s how you run a backup server.

    $ backsum --all

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
