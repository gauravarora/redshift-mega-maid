RedShift Mega Maid
==================

This project is a simple Docker container built from [awslabs/amazon-redshift-utils][1].  It's purpose is to `VACUUM` and `ANALYZE` a RedShift Cluster as a background job.

## Development

This project really depends on [awslabs/amazon-redshift-utils][1].  If you want to fix bugs & make changes to the script, fork that repo & send Pull Requests upstream!

## Building

This container uses a single `Makefile` for ease of building & deployment.  It also uses a basic "Build Tools" container that includes the standard gcc + make toolchain.  This should make running in any given CI environment that supports Docker easy.

## `make container-build`

This spins up a clean docker container, mounting in the project directory, and calls `make clean build`.

## `make build`

This runs `docker build` to install the script's dependencies & build the container.

## `make package`

This uses `Dockerfile` to build the releaseable docker container.

## `make deploy`

This will execute `aws ecr get-login`, then push the container to the [EC2 Container Services Registry (ECR)](https://console.aws.amazon.com/ecs/home?region=us-east-1#/repositories).  You are responsible for setting up ECR in your own AWS account.

# Deploy

We're tagging our images based on date and git hash, and also with `latest`.  The container should now be in the ECR (you can get the list of images in ECR with `aws ecr list-images --repository-name redshift-mega-maid`).

# Running

TODO: Kubernetes Deployment option

The container takes environment variables to pass to the `analyze-vacuum-schema.py` script as arguments.  **Most** are specified in `Dockerfile` as defaults but can be overridden.  As a general rule, the environment variable names follow the convention: `$MM_ARGUMENT_NAME`, where the cooresponding command line argument would be `--argument-name`.  Prefix `MM_` to the argument name, while replacing all dashes (`-`) with underscores (`_`).

Required environment variables are:

 - `MM_DB_NAME`
 - `MM_DB_USER`
 - `MM_DB_PASS`
 - `MM_DB_HOST`
 - `MM_DB_SCHEMA`
 - `MM_DB_TABLE`

You may run the docker container with:

    docker run --rm -e MM_DB_NAME=your_db_name -e MM_DB_USER=your_db_user \
                    -e MM_DB_PASS=your_db_pass -e MM_DB_HOST=aaa.us-west-2.redshift.amazonaws.com \
                    -e MM_DB_SCHEMA=your_db_schema -e MM_DB_TABLE=your_db_table \
               returnpath/redshift-mega-maid:latest

# Working with the Container

## Logs

Within the container the logs are simply printed to stdout via `/dev/stdout`.  To override this, set `MM_OUTPUT_FILE` to something else.  If you wish to persist logs, you will want to pass in a [volume mount][2] for the container to write the file to with `-v`.

## Configuration

By default `docker run` will run with `ENTRYPOINT`: 

    /bin/sh -c python /opt/amazon-redshift-utils/src/AnalyzeVacuumUtility/analyze-vacuum-schema.py

The default arguments are specified in `CMD` as:

    --db $MM_DB_NAME --db-user $MM_DB_USER --db-pwd $MM_DB_PASS --db-port $MM_DB_PORT --db-host $MM_DB_HOST --schema-name $MM_DB_SCHEMA  --table-name $MM_DB_TABLE --output-file $MM_OUTPUT_FILE --debug $MM_DEBUG  --ignore-errors $MM_IGNORE_ERRORS  --slot-count $MM_SLOT_COUNT  --min-unsorted-pct $MM_MIN_UNSORTED_PCT --max-unsorted-pct $MM_MAX_UNSORTED_PCT --deleted-pct $MM_DELETED_PCT --stats-off-pct $MM_STATS_OFF_PCT --max-table-size-mb $MM_MAX_TABLE_SIZE_MB

The default environment variables are set int the `Dockerfile` via `ENV`:

    ENV MM_DB_SCHEMA public
    ENV MM_DB_PORT 5439
    ENV MM_OUTPUT_FILE /dev/stdout
    ENV MM_DEBUG True
    ENV MM_IGNORE_ERRORS False
    ENV MM_SLOT_COUNT 2
    ENV MM_MIN_UNSORTED_PCT 5
    ENV MM_MAX_UNSORTED_PCT 50
    ENV MM_DELETED_PCT 15
    ENV MM_STATS_OFF_PCT 10
    ENV MM_MAX_TABLE_SIZE_MB 700*1024


Since we're using an `ENTRYPOINT`, rather than `CMD` in `Dockerfile` any flags you pass to `docker run` after the image will be appended after the `ENTRYPOINT`. This means that if you want to run other commands inside the container (e.g.: spawn a shell to interactively use other tools in [awslabs/amazon-redshift-utils][1]), you'll have to override the `ENTRYPOINT` with:

    docker run --entrypoint='/path/to/your-entrypoint-here'

## Getting into the Container

If for some reason you need to run a container and get a shell you need to override the entrypoint: `docker run -it -entrypoint=/bin/bash <IMAGE>`


[1]: https://github.com/awslabs/amazon-redshift-utils.git
[2]: https://docs.docker.com/engine/userguide/containers/dockervolumes/
