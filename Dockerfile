FROM amsokol/centos-java8:latest
MAINTAINER Alexander Sokolovsky <amsokol@gmail.com>

# User root user to install software
USER root

# Execute system update
RUN yum -y update && yum clean all

# set Moscow time zone
RUN rm /etc/localtime && ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r activemq -g 1000 && useradd -u 1000 -r -g activemq -m -d /opt/activemq -s /sbin/nologin -c "ActiveMQ user" activemq

# Set the working directory to activemq's user home directory
WORKDIR /opt/activemq

# Set the WILDFLY_VERSION env variable
ENV ACTIVEMQ_VERSION 5.11.1

# Add the ActiveMQ distribution to /opt, and make activemq the owner of the extracted tar content
ADD assets/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz /opt/activemq/
RUN mv apache-activemq-$ACTIVEMQ_VERSION apache-activemq

# Set admin console passwords
RUN sed -i 's/admin: admin, admin/admin: PASSWORD, admin/g' apache-activemq/conf/jetty-realm.properties
RUN sed -i 's/user: user, user/user: PASSWORD, user/g' apache-activemq/conf/jetty-realm.properties

# Set owner recursive
RUN chown -R activemq:activemq apache-activemq

# Specify the user which should be used to execute all commands below
USER activemq

# Set the JAVA_HOME variable to make it clear where Java is located
ENV JAVA_HOME /usr/java/latest

# Expose the folders we're interested in
VOLUME /opt/activemq/apache-activemq/data

EXPOSE 1883 5672 8161 61613 61614 61616

ENTRYPOINT ["/bin/sh", "-c", "/opt/activemq/apache-activemq/bin/activemq console"]
