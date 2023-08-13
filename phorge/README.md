# README

Dockerized setup for running Phorge in a container. Based on: <https://github.com/cooperspencer/phorge>

## Usage

Common tasks are facilitated using the `./manage` utility script:

| Command | Purpose |
| --- | --- |
| `./manage up` | Rebuild and start all containers in the background. Alias for `docker-compose up` with some flags. |
| `./manage phorge-enter` | Enter the Phorge container with bash. |
| `./manage db-repl` | Start a MySQL REPL in the databse container. |
| `./manage db-dump-restore FILE.sql` | Restore a database dump from the host into the database container. **THIS  WILL OVERWRITE THE DATABASE** |
| `./manage recover USERNAME` | Generate one-time login link for a user. |

## Migration plan from Rudy

1. Dump database from Rudy using `mysqldump --user phabricator --password --all-databases --result-file=./dump.sql`
2. Move `dump.sql` to apps VM
3. Run `./manage db-dump-restore dump.sql` to restore the database in the new container
4. Profit

## Tweaking

- Adjust `innodb_buffer_pool_size` in `phorge/mysql-config/custom_config.cnf`

## Updating phorge

Please update `PHORGE_SHA` and `ARCANIST_SHA` in the Dockerfile to the latest commit sha from
[phorge](https://we.phorge.it/source/phorge/repository/master/) and [arcanist](https://we.phorge.it/source/arcanist/repository/master/).

Then rebuild and restart the container.
