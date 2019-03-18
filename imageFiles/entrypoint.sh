#!/bin/bash
set -e

if [ ! $# -eq 0 ]; then
	exec "$@"
else
	exec /sbin/runit-init
fi
