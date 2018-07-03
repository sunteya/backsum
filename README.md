# Backsum

backsum is docker base the file system backup tools, it will incremental backup remote file to local storage.

## Installation

Add docker-compose config file and start script:

    wget https://github.com/sunteya/backsum/raw/master/contrib/docker-compose.yml
    wget https://github.com/sunteya/backsum/raw/master/contrib/start-backsum
    chmod +x start-backsum

## Usage

First, enter you backup project, it will run backsum docker image base on project's name folder.

    ./start-backsum PROJECT_NAME

In docker container, you can should backup.sh script

    touch backup.sh
    chmod +x backup.sh

    vi backup.sh

    #!/usr/bin/env bash
    set -x
    backsum SERVER_HOST:/etc :/root :/usr/local
    cleanup 5 # keep last 5 backups

Finally, you can backup you server in container.

    ./backup.sh

Or, run it on you machine.

    ./start-backsum PROJECT_NAME ./backup.sh


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
