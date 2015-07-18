#!/bin/sh

# Just some fancy colors
RED="\033[31m"
GREEN="\033[32m"
CYAN="\033[36m"
ORANGE="\033[33m"
NC="\033[0m"
STDIN=""
project_name=""
project_path=""
valid_path=0
end=""
template=""

#Check if command exist on system function
command_exists () {
    which $1 > /dev/null;
}

#Docker initialisation function
docker_init(){
    if ! command_exists docker; then
    	echo "$ORANGE Docker is not install. Would you install it ? \n(y/n)$NC";
    	read STDIN;
    	if [ "$STDIN" = "y" ]; then
    			sudo apt-get update;
    			sudo apt-get install -y docker;
    			sudo apt-get install -y docker.io;
    			sudo apt-get clean;
    	else
    		echo "$RED Script Abort. $NC";
    		exit 2;
    	fi
    else
    	echo "$CYAN Launch Docker service$NC";
    	sudo systemctl start docker;
    	echo "$CYAN Pull container image hybridapp from dockerhub$NC";
    	docker pull avallete/hybridapp
    fi
}

docker_clean(){
    sudo killall docker;
    sudo systemctl restart docker;
    sudo docker images -a | grep '<none>' | awk '{print $3}' | xargs docker rmi -f;
    sudo docker ps -a | grep 'ago' | awk '{print $1}' | xargs docker rm -f;
}

hybridapp_create(){
    echo "$GREEN Create a new ionic project: $NC";
    while [ "$project_name" = "" ]
    do
    	echo -n "$CYAN Name of project: $NC";
    	read project_name;
    done
    while [ "$template" != "sidemenu" ] && [ "$template" != "tabs" ] && [ "$template" != "blank" ]
    do
    	echo -n "$CYAN Template of project [blank | tabs | sidemenu]: $NC";
    	read template;
    done

    # Create the new project
    docker run -ti --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $PWD:/myApp:rw avallete/hybridapp ionic start $project_name $template;
    cd $project_name;
    #Init the new project
    docker run -ti --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $PWD:/myApp:rw avallete/hybridapp npm install -g;
}


hybridapp_dev(){
    while [ 1 ]
    do
    	echo -n "$GREEN Project Absolute path: $NC";
    	read project_path;
    	if test -s "$project_path/ionic.project"; then
    		project_path=`realpath $project_path`;
    		xterm -e docker run -ti --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $project_path:/myApp:rw avallete/hybridapp ionic serve &
    		xterm -e docker run -ti --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $project_path:/myApp:rw avallete/hybridapp gulp watch &
    		while [ "$end" != "q" ]
    		do
    			echo "$RED Type q for quit$NC";
    			read end;
    		done
    		docker_clean;
    		exit 0;
    	else
    		echo "$RED $project_path path is incorrect, please enter a correct path.$NC";
    	fi
    done
}

if [ $# -eq 0 ]; then
		echo "$RED Usage: hybridapp [init | create | dev]$NC";
		exit 1;
elif [ "$1" = "init" ]
then
		docker_init;

elif [ "$1" = "create" ]
		hybridapp_create;
then
elif [ "$1" = "dev" ]
then
	hybridapp_dev;
else
	echo "$RED Invalid argument $1. Usage: hybridapp [init | create | dev]$NC";
	exit 1;
fi
