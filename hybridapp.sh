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
    			apt-get update;
    			apt-get install -y docker;
    			apt-get install -y docker.io;
    			apt-get clean;
    	else
    		echo "$RED Script Abort. $NC";
    		exit 2;
    	fi
    else
    	echo "$CYAN Launch Docker service$NC";
    	systemctl start docker;
    	echo "$CYAN Build container image hybridapp from dockerhub$NC";
    	docker build --force-rm=true --no-cache=true -t avallete/hybridapp ./
    fi
}

#Check if xterm is installed
xterm_init(){
    if ! command_exists xterm; then
    	echo -n "$RED Xterm is not installed. Would you install it ? (y/n) $NC";
	read STDIN;
	if [ "$STDIN" = "y" ]; then
		apt-get update;
    		apt-get install -y xterm;
    		apt-get clean;
	else
    		echo "$RED Script Abort. $NC";
    		exit 2;
	fi
    fi
}

#Clean all docker images/process from the computer
docker_clean(){
    killall docker;
    systemctl restart docker;
    docker images -a | grep '<none>' | awk '{print $3}' | xargs docker rmi -f;
    docker ps -a | grep 'ago' | awk '{print $1}' | xargs docker rm -f;
}

#Create and init a new ionic project
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
    docker run --rm -ti --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $PWD:/myApp:rw avallete/hybridapp ionic start $project_name $template;
    #Init the new project
    docker run --rm -ti --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v "$PWD/$project_name":/myApp:rw avallete/hybridapp npm install;
    sudo chown -R $USER:$USER "$PWD/$project_name"
    echo "$RED Clean all docker images$NC";
    docker_clean;
}

#Launch ionic serve and gulp watch for continue stream workflow.
hybridapp_dev(){
    xterm_init;
    while [ 1 ]
    do
    	echo -n "$GREEN Project path: $NC";
    	read project_path;
    	if test -s "$project_path/ionic.project"; then
    		project_path=`realpath $project_path`;
    		xterm -e docker run --rm -ti --net host --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $project_path:/myApp:rw avallete/hybridapp ionic serve &
    		xterm -e docker run --rm -ti --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $project_path:/myApp:rw avallete/hybridapp gulp watch &
    		while [ "$end" != "q" ]
    		do
    			echo "$RED Type q for quit or i for launch a shell in your container$NC";
    			read end;
			if [ "$end" = "i" ]; then
    				xterm -e docker run --rm -ti --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v $project_path:/myApp:rw avallete/hybridapp /bin/bash
			fi
    		done
		echo "$RED Clean all docker images$NC";
    		docker_clean;
    		exit 0;
    	else
    		echo "$RED $project_path path is incorrect, please enter a correct path.$NC";
    	fi
    done
}

#main script base
if [ $# -eq 0 ]; then
		echo "$RED Usage: hybridapp [init | create | dev]$NC";
		exit 1;
elif [ "$1" = "init" ]
then
		docker_init;

elif [ "$1" = "create" ]
then
		hybridapp_create;
elif [ "$1" = "dev" ]
then
		hybridapp_dev;
else
	echo "$RED Invalid argument $1. Usage: hybridapp [init | create | dev]$NC";
	exit 1;
fi
