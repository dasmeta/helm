FROM ubuntu:18.04

WORKDIR /home/mongobi

RUN apt-get update && \
    apt-get install -y libssl1.0.0 libssl-dev libgssapi-krb5-2 openssl wget sed rsyslog sudo

RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

RUN wget https://info-mongodb-com.s3.amazonaws.com/mongodb-bi/v2/mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5.tgz && \
    tar -xvzf mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5.tgz

WORKDIR /home/mongobi/mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5

RUN install -m755 bin/mongo* /usr/local/bin/

RUN mkdir /home/mongobi/mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5/log && \
    cd log && \
    touch sqld.log

WORKDIR /home/mongobi/mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5

COPY ./certs /home/mongobi/mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5/certs

EXPOSE 3307

CMD ["mongosqld", "--config=/home/mongobi/mongodb-bi-linux-x86_64-ubuntu1804-v2.14.5/mongosqld/config.yaml"]
