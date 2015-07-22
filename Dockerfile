FROM     ubuntu:14.04.2
MAINTAINER avallete [at] student [dot] 42 [dot] fr

# make sure the package repository is up to date and install node & git & ionic necessary
RUN apt-get update &&  \
    apt-get install -y npm && ln -s /usr/bin/nodejs /usr/local/bin/node && \
    apt-get upgrade -y 

RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get clean

#make sure node is lastest version
RUN npm cache clean -f && npm install -g n && n stable


#ANDROID (Uncomment next lines if you want dev on Andoid and download SDK (That can be long)) -->
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y -q python-software-properties software-properties-common && apt-get clean
RUN add-apt-repository ppa:webupd8team/java -y
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get update && apt-get -y install oracle-java7-installer && apt-get clean
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect ant wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 qemu-kvm kmod && apt-get clean
RUN cd /opt && wget --output-document=android-sdk.tgz --quiet http://dl.google.com/android/android-sdk_r24.2-linux.tgz && tar xzf android-sdk.tgz && rm -f android-sdk.tgz
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools
RUN echo ANDROID_HOME="${ANDROID_HOME}" >> /etc/environment
RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --all --no-ui --filter platform-tools,tools,build-tools-22.0.1,android-22,extra-android-support,extra-android-m2repository,extra-google-m2repositor"]
#<------------------

EXPOSE 8100
EXPOSE 35729

RUN npm install -g bower
RUN npm install -g cordova
RUN npm install -g ionic
RUN npm install -g gulp 
RUN npm install -g grunt
RUN chmod -R g+rwx /root
WORKDIR myApp
RUN chmod -R g+rwx /myApp
CMD ["ionic", "serve"]
