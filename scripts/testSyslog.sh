#!/bin/bash

printf "###### Creating test container ######\n"
docker create --name BaseImage-test edofede/baseimage:latest
printf "###### Starting test container ######\n"
docker start BaseImage-test
sleep 2

printf "###### Checking syslog-ng startup ######\n"
log=$(docker logs --tail 1 BaseImage-test |sed 's/.*\(syslog-ng starting up\).*/\1/')
if [[ "$log" != "syslog-ng starting up" ]]; then
	printf "Error: syslog-ng not started\n"
	exit 1;
fi



docker exec -ti BaseImage-test logger "STDOUT test message"
log=$(docker logs --tail 1 BaseImage-test |sed 's/.*\(STDOUT test message\).*/\1/')
if [[ "$log" != "STDOUT test message" ]]; then
	printf "Error: test message to STDOUT failed\n"
	exit 1;
fi


docker exec -ti BaseImage-test logger -s "STDERR test message"
log=$(docker logs --tail 1 BaseImage-test |sed 's/.*\(STDERR test message\).*/\1/')
if [[ "$log" != "STDERR test message" ]]; then
	printf "Error: test message to STDERR failed\n"
	exit 1;
fi

printf "###### Stopping test container ######\n"
docker stop BaseImage-test
printf "###### Removing test container ######\n"
docker rm BaseImage-test
