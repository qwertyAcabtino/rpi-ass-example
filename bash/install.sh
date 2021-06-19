#!/bin/bash

# TODO
# Use absolute path for moving around
# Check that all the needed tools are installed before hand.

CMD_PREFIX=">"

function add_secret_entry(){
	SOME_PASSWORD=$(xkcdpass | tr ' ' -)
	DB_ENTRY=$1
	DOCKER_SECRET_NAME=$2
	MASTER_PASSWORD=$3
	KEEPASS_DATABASE_FILE=$4
	echo "${CMD_PREFIX} Storing ${DB_ENTRY}"
	{ echo ${MASTER_PASSWORD}; echo ${SOME_PASSWORD}; } | keepassxc-cli add -q -p ${KEEPASS_DATABASE_FILE} ${DB_ENTRY} 1> /dev/null
	set +e
	docker secret rm ${DOCKER_SECRET_NAME} 1> /dev/null
	set -e
	echo ${SOME_PASSWORD} | docker secret create ${DOCKER_SECRET_NAME} - 1> /dev/null
	echo "${CMD_PREFIX} Created docker secret ${DOCKER_SECRET_NAME}"
}

echo "docker swarm init..."
docker swarm init 2> /dev/null

set -e # exit when any command fails

KEEPASS_DATABASE_FILE=./pass.kdbx
LOCK_FILE=./rpi-ass.lock

if [ -f "$LOCK_FILE" ]; then
	read -p "$LOCK_FILE exists. This means a previous this script was previously ran. Continuing will will DELETE all data and changes. Do you want to continue? (Y/n) " -n 1 -r
	echo    # (optional) move to a new line
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo "${CMD_PREFIX} Aborting execution. Bye."
	    exit 1
	else 
		rm ${KEEPASS_DATABASE_FILE} 
	fi
else
	touch ${LOCK_FILE}
fi

MASTER_PASSWORD=$(xkcdpass | tr ' ' -)
echo "=== Caution! ==="
echo "${CMD_PREFIX} Master password of your keepass file: ${MASTER_PASSWORD}"
echo "=== Store that password in a safe place! ==="

{ echo ${MASTER_PASSWORD}; echo ${MASTER_PASSWORD}; } | keepassxc-cli db-create -q -p ${KEEPASS_DATABASE_FILE}
echo "${CMD_PREFIX} Keepass database store created."

# Set up fresh rss
add_secret_entry "rpi-aas-fresh-rss-db-password" "rpi_aas_fresh_rss_db_password" $MASTER_PASSWORD $KEEPASS_DATABASE_FILE
cd ./services/fresh-rss
docker-compose down
docker-compose rm
docker-compose up -d --force-recreate
cd ../../
