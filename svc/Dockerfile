FROM bitnami/minideb:jessie
LABEL maintainer="Razmik Avetikyan <razmik.avetikyan@dasmeta.com>"

#RUN install_packages apt-transport-https cron curl zip lsb-release unzip
RUN install_packages zip unzip cron python3-pip groff
RUN pip3 install awscli typing
#RUN curl --insecure "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
#RUN unzip awscli-bundle.zip
#RUN ./awscli-bundle/install -b ~/bin/aws

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/4.0 main" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN install_packages mongodb-org-shell mongodb-org-tools

RUN mkdir -p /backup /restore /config && chmod 0777 /config

COPY migrate_backup_aws.sh restore.sh run.sh tmp_mongo_user.js /

RUN chmod +x /run.sh

ENTRYPOINT ["/bin/bash", "/run.sh"]
