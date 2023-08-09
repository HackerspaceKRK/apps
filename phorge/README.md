# README

Dockerized setup for running Phorge in a container. Based on: https://github.com/cooperspencer/phorge

## Differences from the original dockerfile

Dcokerfile located in `phorge-container/Dockerfile` (as well ass associated configs).

- Use debian 12 (bookworm)
- Remove ssh server support
- Fetch Phorge commits by sha instead of downloading the latest one at build time
- Disable `opcache.validate_timestamps=1` in `php.ini` for performance reasons


## Updating phorge

Please update `PHORGE_SHA` and `ARCANIST_SHA` in the Dockerfile to the latest commit sha from
[phorge](https://we.phorge.it/source/phorge/repository/master/) and [arcanist](https://we.phorge.it/source/arcanist/repository/master/).

Then rebuild and restart the container.
