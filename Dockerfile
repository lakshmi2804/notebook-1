FROM ubuntu:latest
# ...
ENV TZ=US/Eastern
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get update && apt-get install -y \software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y \python3.7 \python3-pip
RUN python3.7 -m pip install pip
RUN apt-get update && apt-get install -y \python3-distutils \python3-setuptools
RUN python3.7 -m pip install pip --upgrade pip

RUN pip install databricks-cli
RUN apt-get -y update
RUN apt-get install -y jq
RUN apt-get install -y curl
#RUN apt-get install -y python3


