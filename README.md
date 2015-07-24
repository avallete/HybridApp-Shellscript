# Overview
This is a simple docker for dev with ionic/gulp/grant.
And build and run on Android (optionnal)

# Little Docker tips:
By default, doker images goes on /var/lib/docker. If you have a little OS-drive (like SSD).
You can use symbolic link and redirect the docker storage location.
```
  ln -s /your/path /var/lib/docker
```

One more thing, with ionic, you need use long command for launch your docker.
I advise you: use alias

```
  alias dockerun="docker run --rm --net host -ti --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v \$PWD:/myApp:rw"
  alias dockerclr="docker ps -a | grep Exited | awk {'print $1'} | xargs docker rm"
  alias dockerclri="docker images -a | grep none | awk '{print $3}' | xargs docker rmi"
```

Firs alias provide you a easy way for dev an ionic project like that:

```
  cd {project_folder}
  dockerun {imagename} /bin/bash
  ionic serve
```

The others aliases just some command for clean your unused container.
Think to check them regulary with:
```
  docker images -a
  docker ps -a
```

Start by remove unused container listed in `docker ps -a` with:
```
  docker rm {container id}
```

And do the same for images:
```
  docker images -a
  docker rmi {image id}
```

# Installation guide

## Android
If you don't want build on Android or if you want a lighter docker image, comment
this section in Dockerfile.

## Installation

Be sure you have docker installed on your computer.
Clone the project and launch:
```
  cd {clone repo}
  docker build -t {whatyouwant} ./
```

# How to run a new project:
```
  mkdir new
  cd new
  dockerun {imagename} ionic start
  dockerun {imagename} npm install
  dockerun {imagename} ionic setup sass
  sudo chown -R new (for allow you to edit files)
```

## How to build for android
```
  dockerun {imagename} ionic platform add android
  dockerun {imagename} ionic build android
  (if you have a android device plugin with debugmode enabled you can do)
  dockerun {imagename} ionic run
```

## How to test on browser
One terminal with project already init
And launch:
```
  dockerun {imagename} ionic serve
```
