#!/bin/bash
sudo yum update -y
sudo yum -y install httpd
sudo systemctl start httpd
sudo systmectl enable httpd
sudo echo "hello world01" > /var/www/html/index.html

