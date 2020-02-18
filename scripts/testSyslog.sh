#!/bin/bash

source scripts/multiArchMatrix.sh
source scripts/logger.sh

showHelp() {
	echo "Usage: $0 -i <Image name> -t <Tag name> -p <Test only platform (`printf '%s ' "${PLATFORMS[@]}"`)>"
}

while getopts :hi:t:p:g: opt; do
	case ${opt} in
		h)
			showHelp
			exit 0
			;;
		i)
			DOCKER_IMAGE=$OPTARG
			;;
		t)
			DOCKER_TAG=$OPTARG
			;;
		p)
			PLATFORM=$OPTARG
			;;
		g)
			GITHUB_TOKEN=$OPTARG
			;;
		\?)
			echo "Invalid option: $OPTARG" 1>&2
			showHelp
			exit 1
			;;
		:)
			echo "Invalid option: $OPTARG requires an argument" 1>&2
			showHelp
			exit 1
			;;
		*)
			showHelp
			exit 0
			;;
	esac
done
shift "$((OPTIND-1))"


for i in ${!PLATFORMS[@]}; do
	if [ -n "$PLATFORM" ] && [ "${PLATFORMS[i]}" != "$PLATFORM" ]; then
		continue
	fi

	echo ""
	logTitle "Testing image: $DOCKER_IMAGE:$DOCKER_TAG (${PLATFORMS[i]})"
	
	logSubTitle "Running test container"
	scripts/run.sh -i $DOCKER_IMAGE -t $DOCKER_TAG -p ${PLATFORMS[i]} &
	sleep 20
	echo ""

	containerId=$(docker container ls --filter ancestor=$DOCKER_IMAGE:$DOCKER_TAG -q)
	
	logSubTitle "Checking syslog-ng startup"
	log=$(docker logs $containerId 2>&1 |grep 'syslog-ng starting up' |sed 's/.*\(syslog-ng starting up\).*/\1/')
	if [ "$log" != "syslog-ng starting up" ]; then
		logError "Error: syslog-ng not started"
		logError "Aborting..."
		docker stop $containerId
		exit 1;
	fi
	logNormal "[OK] Test passed"
	
	
	logSubTitle "Checking STDOUT logging"
	docker exec -ti $containerId logger "STDOUT test message"
	sleep 1
	log=$(docker logs --tail 1 $containerId |sed 's/.*\(STDOUT test message\).*/\1/')
	if [ "$log" != "STDOUT test message" ]; then
		logError "Error: test message to STDOUT failed"
		logError "Aborting..."
		docker stop $containerId
		exit 1;
	fi
	logNormal "[OK] Test passed"
	
	
	logSubTitle "Checking STDERR logging"
	docker exec -ti $containerId logger -s "STDERR test message"
	sleep 1
	log=$(docker logs --tail 1 $containerId |sed 's/.*\(STDERR test message\).*/\1/')
	if [ "$log" != "STDERR test message" ]; then
		logError "Error: test message to STDERR failed"
		logError "Aborting..."
		docker stop $containerId
		exit 1;
	fi
	logNormal "[OK] Test passed"
	
	docker stop $containerId
	sleep 3
	logNormal "Done"

done