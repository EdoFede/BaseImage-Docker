#!/bin/bash

source scripts/multiArchMatrix.sh
source scripts/logger.sh

function cleanup () {
	logSubTitle "Stopping test container"
	docker stop BaseImage-test
	logSubTitle "Removing test container"
	docker rm BaseImage-test
}


echo ""
logTitle "Testing image: edofede/baseimage:$1"

logSubTitle "Creating test container"
docker create --name BaseImage-test edofede/baseimage:$1


logSubTitle "Starting test container"
docker start BaseImage-test
sleep 2


logSubTitle "Checking syslog-ng startup"
log=$(docker logs --tail 1 BaseImage-test |sed 's/.*\(syslog-ng starting up\).*/\1/')
if [[ "$log" != "syslog-ng starting up" ]]; then
	logError "Error: syslog-ng not started"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Test passed"


logSubTitle "Checking STDOUT logging"
docker exec -ti BaseImage-test logger "STDOUT test message"
log=$(docker logs --tail 1 BaseImage-test |sed 's/.*\(STDOUT test message\).*/\1/')
if [[ "$log" != "STDOUT test message" ]]; then
	logError "Error: test message to STDOUT failed"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Test passed"


logSubTitle "Checking STDERR logging"
docker exec -ti BaseImage-test logger -s "STDERR test message"
log=$(docker logs --tail 1 BaseImage-test |sed 's/.*\(STDERR test message\).*/\1/')
if [[ "$log" != "STDERR test message" ]]; then
	logError "Error: test message to STDERR failed"
	logError "Aborting..."
	cleanup
	exit 1;
fi
logNormal "[OK] Test passed"

cleanup
