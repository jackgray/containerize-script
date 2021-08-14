#!/usr/bin/env bash

# Containerizes and runs a shell script defined by CLI arg

# TODO: add all scripts to github to be searched and pulled given appropriate input argument
# TODO: parse script extension to build with appropriate base image
#    i.e. use bash to make shell script containerization faster
#         use



# make 3rd input argument 'TRUE' to troubleshoot

 
# SETUP
CURRENT_DIR=$(pwd)
PATH_TO_SCRIPT="$CURRENT_DIR/$1"
SCRIPT_NAME=$1

# local path to share data with container process
BIND_PATH=$2

# separate extension and filename into two vars
CONTAINER_NAME=$(echo "$1" | cut -f 1 -d '.')
TYPE=$(echo "$1" | cut -f 2 -d '.')


# setup container based on script type
case $TYPE in 
    "sh") 
        CMD_CMD="bash" && BASE_IMAGE="bash:4.4"
        ;;
    "py") 
        CMD_CMD="python3" && BASE_IMAGE="ubuntu"
        ;;
    "js") 
        CMD_CMD="npm" && BASE_IMAGE="nginx"
        ;;
esac

if $verbose
then
printf "\nLAUNCHING SCRIPT AS A CONTAINER\n*****************************************************\n\n"
echo "Directory of script to be containerized:" 
printf "%s\n\n" "$PATH_TO_SCRIPT"
printf "using base image \"%s\"\n\n" $BASE_IMAGE
printf "filetype: \"%s\" \n" $TYPE
fi

if $verbose
then
printf "Name of container:\n'%s'\n\n" "$CONTAINER_NAME"
fi

# make Dockerfile path stdin - leave no trace
# IMPORTANT: buildkit MUST be used for file-less (stdin) context passing
#            for CMD to execute on run
docker_build(){
    DOCKER_BUILDKIT=1 docker build --no-cache -t containerized-$CONTAINER_NAME:buildimage -f- . <<EOF
    FROM $BASE_IMAGE
    WORKDIR /app
    COPY $SCRIPT_NAME .
    RUN chmod +x $SCRIPT_NAME
    CMD ["$CMD_CMD", "$SCRIPT_NAME"]
EOF
}

docker_run(){
    echo "Binding output from container volume to local working directory at $BIND_PATH"
    docker run -i \
    --name $CONTAINER_NAME \
    --mount type=bind,source="$(pwd)",target=/app \
    containerized:fileless
}

containerize(){
    if $verbose
    then
    printf "\n\nBuilding container '$CONTAINER_NAME'...\n\n"
    fi
    docker_build
    if $verbose
    then
    printf "Executing docker run...\n\n"
    fi
    docker_run
    if $verbose
    then
    printf "\n\ncontainerization complete\n\n"
    fi
}
containerize
