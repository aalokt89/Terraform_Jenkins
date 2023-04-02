#!/bin/bash
sudo yum update -y

sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

sudo amazon-linux-extras install java-openjdk11 -y && sudo yum install jenkins -y
sudo systemctl daemon-reload

sudo systemctl enable jenkins
sudo systemctl start jenkins
