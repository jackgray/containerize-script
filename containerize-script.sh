#!/usr/bin/env bash

# Containerizes and runs any program in its smallest possible environment defined by CLI arg

# TODO: add all scripts to github to be searched and pulled given appropriate input argument
# TODO: set up argument parser
 
# SETUP
verbose=TRUE
CURRENT_DIR=$(pwd)
PATH_TO_SCRIPT="$CURRENT_DIR/$1"
SCRIPT=$1

# local path to share data with container process
BIND_PATH=$2

# separate extension and filename into two vars
SCRIPT_NAME=$(echo "$1" | cut -f 1 -d '.')
TYPE=$(echo "$1" | cut -f 2 -d '.')


# setup container based on script type
case $TYPE in 
    "sh") 
        CMD_CMD="bash" && BASE_IMAGE="bash"
        ;;
    "py") 
        CMD_CMD="python3" && BASE_IMAGE="ubuntu"
        ;;
    "js") 
        CMD_CMD="npm" && BASE_IMAGE="nginx"
        ;;
    *)
        CMD_CMD="bash" && BASE_IMAGE="bash"
        ;;
esac

# set image name, tag, and container name using input info
IMAGE_NAME='containerizer-'$SCRIPT_NAME':'$BASE_IMAGE
CONTAINER_NAME="containerized-"$SCRIPT_NAME"-"$date

#--------------------------------------------------
if $verbose
then
printf "\nLAUNCHING SCRIPT AS A CONTAINER\n*****************************************************\n\n"
echo "Directory of script to be containerized:" 
printf "%s\n\n" "$PATH_TO_SCRIPT"
printf "using base image \"%s\"\n\n" $BASE_IMAGE
printf "filetype: \"%s\" \n\n" $TYPE
printf "Naming build image:\n'%s'\n\n" "$IMAGE_NAME"
fi
#--------------------------------------------------

# make Dockerfile path stdin - leave no trace
# IMPORTANT: buildkit MUST be used for file-less (stdin) context passing
#            for CMD to execute on run
docker_build(){
    DOCKER_BUILDKIT=1 docker build --no-cache --pull -t $IMAGE_NAME -f- . <<EOF
    FROM $BASE_IMAGE
    WORKDIR /app
    COPY $SCRIPT .
    RUN chmod +x $SCRIPT
    CMD ["$CMD_CMD", "$SCRIPT"]
EOF
}

buildfromfile(){
    docker build .
}

docker_run(){
    echo "Binding output from container volume to local working directory at $BIND_PATH"
    docker run --rm -d \
    --privileged \
    --name $CONTAINER_NAME \
    --mount type=bind,source="$(pwd)",target=/app \
    $IMAGE_NAME
}

containerize(){

    #--------------------------------------------------
    if $verbose
    then
    printf "\n\nBuilding container '$CONTAINER_NAME'...\n\n"
    fi
    #--------------------------------------------------
    
    docker_build

    #--------------------------------------------------
    if $verbose
    then
    printf "Executing docker run...\n\n"
    fi
    #--------------------------------------------------

    docker_run
    
    #--------------------------------------------------
    if $verbose
    then
    printf "\n\ncontainerization complete\n\n"
    fi
    #--------------------------------------------------
}
containerize
