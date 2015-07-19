# HybridApp-Shellscript
A little shell script for create/devellop hybrids app with ionic/cordova/sass/ in docker more easily.
(Test under Ubuntu 14.0)

# Installation guide

## Android

First of all, if you want build/dev on Android and add the SDK in your docker.
Uncomment the "ANDROID" part in the Dockerfile.

## Installation

Clone the project and launch:
```
  cd {clone repo}
  sudo ./hybridapp.sh init
```

And follow the script instruction. He will install all necessary stuff you need for create and devellop your project.

# How that work ?!

## Create a new project

Well, simply launch:
```
  sudo ./hybridapp.sh create
```

## Dev on an existing project

You need to launch:
```
  sudo ./hybridapp.sh dev
```
And follow the script instruction. You can give a relative or absolute path when he ask for.
He will open you 2 new term. One with sass watch. Other with ionic serve.
For quit cleanly make sure you quit the project by type "q" in the script.
But the script destroy all docker running container at the end of session so be careful with it if you have another running container.

# Example of use
```
  git clone https://github.com/avallete/HybridApp-Shellscript.git appDev
  cd appDev
  sudo ./hybridapp.sh init
  sudo ./hybridapp.sh create
  {
    Name of Project: test
    Template: tabs
  }
  sudo ./hybridapp.sh dev
  {
    Path of Project: test | ./test | /absolute/path/test
    (In the ionic serve terminal. Choose your connexion mode (no localhost if you want test with your smartphone))
    (In your browser enter the "Running dev Server" adress)
    (If you want access to shell of your docker type i, if you want quit dev mode type q)
  }
```
