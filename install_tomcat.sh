#!/bin/bash
sudo yum update -y
sudo yum list | grep jdk
sudo yum -y install java-1.8.0-openjdk
sudo yum -y install java-1.8.0-openjdk-devel.x86_64
readlink -f /usr/bin/java
sudo vi /etc/profile
sudo echo -e "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.272.b10-1.amzn2.0.1.x86_64/jre\n
export PATH=$PATH:$JAVA_HOME/bin\n
export CLASSPATH=$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar\n
export CATALINA_HOME=/usr/local/tomcat8.5" > /etc/profile
source /etc/profile
wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
tar xvzf apache-tomcat-8.5.61.tar.gz
sudo mv apache-tomcat-8.5.61 /usr/local/tomcat8.5
sudo echo -e "<Connector port="8080" protocol="HTTP/1.1"\n
               URIEncoding="UTF-8"\n
               connectionTimeout="20000"\n
               redirectPort="8443" />" > /usr/local/tomcat8.5/conf/server.xml
/usr/local/tomcat8.5/bin/startup.sh
