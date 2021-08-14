#!/usr/bin/env bash

# Containerizes and runs a shell script defined by CLI arg

# TODO: add all scripts to github to be searched and pulled given appropriate input argument

# make 2nd input argument 'TRUE' to troubleshoot
verbose=$2 
 
# SETUP
CURRENT_DIR=$(pwd)
PATH_TO_SCRIPT="$CURRENT_DIR/$1"
SCRIPT_NAME=$1
BASE_IMAGE=bash:4.4
# removes extension for file being containerized
CONTAINER_NAME=$(echo "$1" | cut -f 1 -d '.')


if $verbose
then
printf "\nLAUNCHING SCRIPT AS A CONTAINER\n*****************************************************\n\n"
echo "Directory of script to be containerized:" 
printf "%s\n\n" "$PATH_TO_SCRIPT"
printf "using base image \"%s\"\n\n" $BASE_IMAGE
fi

if $verbose
then
printf "Name of container:\n'%s'\n\n" "$CONTAINER_NAME"
fi

# make Dockerfile path stdin - leave no trace
# IMPORTANT: buildkit MUST be used for file-less (stdin) context passing
#            for CMD to execute on run
docker_build(){
    DOCKER_BUILDKIT=1 docker build --no-cache -t containerized:fileless -f- . <<EOF
    FROM ubuntu
    WORKDIR /app
    COPY $SCRIPT_NAME .
    RUN chmod +x $SCRIPT_NAME
    CMD ["bash", "$SCRIPT_NAME"]
EOF
}

docker_run(){
    echo "Binding output from container volume to local working directory."
    docker run --rm -d \
    --name shellname \
    --mount type=bind,source="$(pwd)",target=/app \
    containerized:fileless
}

containerize(){
    docker_build
    docker_run
}
containerize