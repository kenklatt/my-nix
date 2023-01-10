# This file contains customizations I made in my work computer's .bashrc before I
# merged my home-manager configurations.

# Postgres (Tripod)
PSQL_EDITOR="vim"
PSQL_PAGER="pspg"
alias ssr-db="pgcli postgresql://postgres:password@localhost:54321/ssr"
alias tripod-db="pgcli postgresql://postgres:password@localhost:54320/TRIPOD"
alias tripod-db-query="tripodDbQuery"
tripodDbQuery() {
	psql postgresql://postgres:password@localhost:54320/TRIPOD \
		--no-align \
		--quiet \
		--tuples-only \
		--command "$1"
	#| head -n 1
}
alias tripod-db-query-file="tripodDbQueryFile"
tripodDbQueryFile() {
	psql postgresql://postgres:password@localhost:54320/TRIPOD \
		--no-align \
		--quiet \
		--tuples-only \
		--file "$1"
	#| head -n 1
}

# ZFS Dataset Operations on DM application databases
# Create a new dataset: https://docs.oracle.com/cd/E19253-01/819-5461/gamnq/index.html
alias tripod-snapshots="zfs list -t snapshot rpool/docker/pgdata"
alias tripod-snapshot="tripodSnapshot"
tripodSnapshot() {
	zfs snapshot rpool/docker/pgdata@$1
}
alias tripod-rollback="tripodRollback"
tripodRollback() {
	docker stop db \
	&& zfs rollback rpool/docker/pgdata@$1 \
	&& docker start db
}
alias tripod-snapshot-destroy="tripodDestroySnapshot"
tripodDestroySnapshot() {
	zfs destroy rpool/docker/pgdata@$1
}

# Made with
# zfs create -o mountpoint=/var/lib/docker/volumes/104dd7095a613111d9014e41a99325b4a17ef2b9b63984e41688e08e33abc959 rpool/docker/sensor-pgdata
# TODO: Will need to recreate the dataset when the volume id changes. Should set that to a fixed name.
sensorDbContainerId() {
	echo $(docker container inspect sensor-service_sensor_db_1 --format '{{.Id}}')
}
sensorDbVolumeId() {
	# Note: This presumes the volume is the first "mount"
	containerId=$(sensorDbContainerId)
	mounts=$(docker inspect -f '{{.Mounts}}' "$containerId")
	echo $mounts | awk '{print $2}'
}
alias sensor-snapshots="zfs list -t snapshot rpool/docker/sensor-pgdata"
alias sensor-snapshot="sensorSnapshot"
sensorSnapshot() {
	zfs snapshot rpool/docker/sensor-pgdata@$1
}
alias sensor-rollback="sensorRollback"
sensorRollback() {
	docker stop dm-sensor-database \
	&& zfs rollback rpool/docker/sensor-pgdata@$1 \
	&& docker start dm-sensor-database
}
alias sensor-snapshot-destroy="sensorDestroySnapshot"
sensorDestroySnapshot() {
	zfs destroy rpool/docker/sensor-pgdata@$1
}
alias sensor-db="pgcli postgresql://postgres:password@localhost:54390/sensor"
###

# Docker (Tripod)
REPOS=$HOME/src
alias tripod-stack-up="$REPOS/tripod/gradlew clean deployDocker && docker-compose -f $REPOS/tripod/installer/build/deploy/docker/docker-compose.yml up -d"
alias tripod-stack-down="$REPOS/tripod/gradlew clean deployDocker && docker-compose -f $REPOS/tripod/installer/build/deploy/docker/docker-compose.yml down"

getRootOfCurrentRepository() {
	echo $(git rev-parse --show-toplevel &>/dev/null)
}

tripodTaskWrapper() {
	cd $REPOS/tripod;
	$@ # Only going to support one passed in function (with its arguments). Otherwise we lose the control structures. (; &&)
	#for function in $@
	#do
	#	$function
	#done
	cd -;
}

configureTripodBuildEnvironment() {
	sdk env;
}

rebuildTripodContainer() {
	$REPOS/tripod/gradlew clean deployDocker
}

startTripodContainer() {
	docker-compose -f $REPOS/tripod/installer/build/deploy/docker/docker-compose.yml up -d tripod
	#$REPOS/tripod/installer/build/deploy/docker/docker-compose-fullstack.yml
}

startTripodFullstack() {
	docker-compose --file $REPOS/tripod/installer/build/deploy/docker/docker-compose-fullstack.yml up -d
}

startTripodLogs() {
	# Thanks to https://unix.stackexchange.com/questions/428456/docker-compose-less-and-sigint
	set -m
	TEMP_LOG_FILE=$(mktemp --suffix '-dev-env-log')
	(trap '' SIGINT \
		&& docker-compose \
			--file $REPOS/tripod/installer/build/deploy/docker/docker-compose.yml \
			logs --follow --timestamps tripod \
			> ${TEMP_LOG_FILE} \
	) &
	less -+S --RAW-CONTROL-CHARS +F -W ${TEMP_LOG_FILE}
	rm ${TEMP_LOG_FILE}
}

tripodCleanDeploy() {
	configureTripodBuildEnvironment \
	; rebuildTripodContainer \
	&& startTripodContainer
}

tripodCleanDeployWithLogs() {
	tripodCleanDeploy \
	&& startTripodLogs
}

runTripodTests() {
	configureTripodBuildEnvironment \
	; $REPOS/tripod/gradlew $1 test # $1 allows for clean to be passed in
}

alias tripod-clean-deploy="tripodTaskWrapper tripodCleanDeploy"
alias tripod-clean-deploy-with-logs="tripodTaskWrapper tripodCleanDeployWithLogs"
alias tripod-clean-fullstack-deploy="$REPOS/tripod/gradlew clean deployDocker && docker-compose -f $REPOS/tripod/installer/build/deploy/docker/docker-compose-fullstack.yml up -d && wget localhost:8080"
alias tripod-deploy="$REPOS/tripod/gradlew deployDocker && docker-compose -f $REPOS/tripod/installer/build/deploy/docker/docker-compose.yml up -d tripod"
alias tripod-logs="tripodTaskWrapper startTripodLogs"
alias tripod-test="tripodTaskWrapper runTripodTests"
alias docker-wipe="docker stop \$(docker ps -q) && yes | docker container prune && yes | docker volume prune"

export MY_WM_USERNAME='kklatt'

# Workflow setup
export WF_RSA_PRIVATE_KEY=$(cat ~/.ssh/wf_rsa | awk 'NR>2 {print last} {last=$0}' | tr -d '\n')
export WF_RSA_PUBLIC_KEY=$(cat ~/.ssh/wf_rsa.pub | awk 'NR>2 {print last} {last=$0}' | tr -d '\n')
export TRIPOD_SA_PASSWORD=$(grep "^systemProp.tripod.service.account.password=" ~/.gradle/gradle.properties | cut -d'=' -f2)
#export ARTIFACTORY_CONTEXT_URL=$(grep "^artifactoryContextUrl=" ~/.gradle/gradle.properties | cut -d'=' -f2)

# Bitbucket API
export BB_USER=kklattwm

alias zfs-home-biggest-snapshots="zfs list -t snapshot rpool/USERDATA/ken_vvxh9x -S used | head"

source ~/.secrets

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/ken/.sdkman"
[[ -s "/home/ken/.sdkman/bin/sdkman-init.sh" ]] && source "/home/ken/.sdkman/bin/sdkman-init.sh"


