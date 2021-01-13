### Install

    cp example.env .env
    cp motion.example.env motion.env
    sudo docker-compose build
    sudo docker-compose run --rm --entrypoint rclone motion config
    sudo docker-compose up

### Help tools

#### Show audio

    sudo docker-compose run --rm --entrypoint arecord motion -l

#### Bash

    sudo docker-compose run --rm --entrypoint bash motion

#### Show rclone storer 

    sudo docker-compose run --rm --entrypoint rclone motion listremotes
