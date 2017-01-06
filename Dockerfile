
FROM ubuntu:16.04
MAINTAINER jecyhw <1147352923@qq.com>
RUN apt update

#install sshd
RUN apt install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:jec' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
EXPOSE 22

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN apt update && apt install -y mongodb-org
RUN mkdir -p /data/db
EXPOSE 27017

RUN apt install -y curl
RUN curl https://install.meteor.com/ | sh
RUN mkdir -p /opt/mongoclient
RUN apt install -y git
RUN git clone https://github.com/rsercano/mongoclient.git /opt/mongoclient
WORKDIR /opt/mongoclient
RUN /usr/local/bin/meteor npm install --unsafe-perm
EXPOSE 3000
ENV MONGO_URL='mongodb://127.0.0.1:27017'


RUN apt install -y vim supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

# docker run -i -t -p 22 -p 27017 -p 3000 -v /home/jecyhw/mongo/dump:/data/mongo
