#!/bin/sh

docker build --build-arg USER_ID=${UID} -t pidos/build:latest .

