# UPDATE EXCHANGE BETA 1.0.0
- add integraion referral system
- referral worker

# CONFIGURATION
configuration on worker

## WORKER
worker for handling integration referral system is ```reward_member``` before running the worker please make sure the database is updated to last migration

### COMMAND LINE
when running using command line just type this on terminal
```bash
$ bundle exec ruby lib/daemons/amqp_daemon.rb reward_member
```

### DOCKER COMPOSE
when running using docker compose make the script like below, and type command ```docker-compose up -Vd reward_member```

```
version: '3.6'

x-daemon: &exchange-daemon
  image: "pexchange:0.1"
  restart: always
  env_file:
    - ../config/exchange.env
    - ../config/kaigara.env
  volumes:
    - /home/back-dev/Documents/alone/rails/pexbank/backend-platform-exchange/app:/home/app/app
    - /home/back-dev/Documents/alone/rails/pexbank/backend-platform-exchange/db:/home/app/db
    - /home/back-dev/Documents/alone/rails/pexbank/backend-platform-exchange/lib:/home/app/lib
    - /home/back-dev/Documents/alone/rails/pexbank/backend-platform-exchange/config/database.yml:/home/app/config/database.yml
    - /home/back-dev/Documents/alone/rails/pexbank/backend-platform-exchange/config/amqp.yml:/home/app/config/amqp.yml
    - /home/back-dev/Documents/alone/rails/pexbank/backend-platform-exchange/config/initializers:/home/app/config/initializers
    - ../config/exchange/seed:/home/app/config/seed
    - ../config/exchange/management_api_v1.yml:/home/app/config/management_api.yml
    - ../config/exchange/plugins.yml:/home/app/config/plugins.yml
    - ../config/exchange/abilities.yml:/home/app/config/abilities.yml
  logging:
    driver: "json-file"
    options:
        max-size: "50m"

reward_member:
    << : *exchange-daemon
    environment:
    - VAULT_TOKEN=${EXCHANGE_MATCHING_VAULT_TOKEN}
    command: bash -c "bundle exec ruby lib/daemons/amqp_daemon.rb trade_executor"
    logging:
      driver: "json-file"
      options:
```