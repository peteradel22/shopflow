#!/bin/bash

yum update -y

yum install -y docker aws-cli

systemctl enable docker
systemctl start docker

aws ecr get-login-password --region us-east-1 | \
docker login --username AWS --password-stdin \
040768516109.dkr.ecr.us-east-1.amazonaws.com

docker pull 040768516109.dkr.ecr.us-east-1.amazonaws.com/shopflow-app:latest

docker run -d --restart always \
-p 3000:3000 \
040768516109.dkr.ecr.us-east-1.amazonaws.com/shopflow-app:latest
