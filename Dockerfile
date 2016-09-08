FROM crystallang/crystal:0.21.1
MAINTAINER Gebhard Woestemeyer <g@ctr.lc>
RUN \
  apt-get update &&\
  apt-get install -y jq curl
RUN mkdir /pwd
ADD . /pwd
WORKDIR /pwd

RUN crystal deps
RUN crystal build -o cobot src/cobot.cr
CMD ["./run"]
