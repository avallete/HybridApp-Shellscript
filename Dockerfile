FROM     ubuntu:14.04.2
MAINTAINER avallete [at] student [dot] 42 [dot] fr

# make sure the package repository is up to date and install node & git & ionic necessary
RUN apt-get update &&  \
    apt-get install -y npm && ln -s /usr/bin/nodejs /usr/local/bin/node && \
    apt-get upgrade -y && \ 
    apt-get install -y git &&\
    apt-get install -y curl &&\
    apt-get clean

#make sure node is lastest version
RUN npm cache clean -f && npm install -g n && n stable

RUN npm install -g cordova ionic gulp sass

RUN ionic start myApp sidemenu

EXPOSE 8100
EXPOSE 35729

#ANDROID
#JAVA
ENV DEBIAN_FRONTEND noninteractive
# install python-software-properties (so you can do add-apt-repository)
RUN apt-get update && apt-get install -y -q python-software-properties software-properties-common && apt-get clean

RUN add-apt-repository ppa:webupd8team/java -y
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get update && apt-get -y install oracle-java7-installer && apt-get clean

#ANDROID STUFF
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod && apt-get clean

# Install Android SDK
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.2-linux.tgz && tar xzf android-sdk.tgz && rm -f android-sdk.tgz

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Install sdk elements
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment

RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --all --no-ui --filter platform-tools,tools,build-tools-22.0.1,android-22,extra-android-support,extra-android-m2repository,extra-google-m2repositor"]
#  add sys-img-armeabi-v7a-android-22 for android emulator
#RUN echo "no" | android create avd \
#                --force \
#                --device "Nexus 5" \
#                --name test \
#                --target android-22 \
#                --abi armeabi-v7a \
#                --skin WVGA800 \
#                --sdcard 512M
# don't work for moment.

WORKDIR myApp
CMD ["ionic", "serve"]
