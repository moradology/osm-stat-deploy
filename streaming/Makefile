CONFIG_NAME := osm-stat-stream-config
CLUSTER_NAME := osm-stat-stream-cluster

INSTANCE_TYPE := m4.large
INSTANCE_ROLE := PlanetDownloaderECSRole
KEYPAIR := ???
SUBNETS := ???
VPC := ???
SECURITY_GROUP := ???

AUGDIFF_STREAM_REPO := TESTING
AUGDIFF_START := 1
AUGDIFF_SOURCE := s3://mojodna-temp/augdiffs/

CHANGESET_STREAM_REPO := TESTING2
CHANGESET_START := 1
CHANGESET_SOURCE := https://planet.osm.org/replication/changesets/

CHANGE_STREAM_REPO := TESTING3
CHANGE_START := 1
CHANGE_SOURCE := https://planet.osm.org/replication/minute/

AWS_LOG_GROUP := osm-stats-stream
AWS_REGION := us-east-1
DB_URI := ???
DB_USER := ???
DB_PASS := ???


docker-compose.local.yml:
	export AUGDIFF_STREAM_REPO=${AUGDIFF_STREAM_REPO}; \
	export CHANGESET_STREAM_REPO=${CHANGESET_STREAM_REPO}; \
	export CHANGE_STREAM_REPO=${CHANGE_STREAM_REPO}; \
	export AWS_LOG_GROUP=${AWS_LOG_GROUP}; \
	export AWS_REGION=${AWS_REGION}; \
	export AUGDIFF_SOURCE=${AUGDIFF_SOURCE}; \
	export CHANGESET_SOURCE=${CHANGESET_SOURCE}; \
	export CHANGE_SOURCE=${CHANGE_SOURCE}; \
	export AUGDIFF_START=${AUGDIFF_START}; \
	export CHANGESET_START=${CHANGESET_START}; \
	export CHANGE_START=${CHANGE_START}; \
	export DB_URI=${DB_URI}; \
	export DB_USER=${DB_USER}; \
	export DB_PASS=${DB_PASS}; \
		../expand.sh docker-compose.local.yml.tpl > docker-compose.local.yml

start-local: docker-compose.local.yml
	docker-compose -f docker-compose.local.yml up

stop-local:
	docker-compose -f docker-compose.local.yml down

docker-compose.deploy.yml:
	export AUGDIFF_STREAM_REPO=${AUGDIFF_STREAM_REPO}; \
	export CHANGESET_STREAM_REPO=${CHANGESET_STREAM_REPO}; \
	export AWS_LOG_GROUP=${AWS_LOG_GROUP}; \
	export AWS_REGION=${AWS_REGION}; \
	export AUGDIFF_START=${AUGDIFF_START}; \
	export CHANGESET_START=${CHANGESET_START}; \
	export DB_URI=${DB_URI}; \
	export DB_USER=${DB_USER}; \
	export DB_PASS=${DB_PASS}; \
		../expand.sh docker-compose.deploy.yml.tpl > docker-compose.deploy.yml

login-aws-registry:
	eval `aws ecr get-login --no-include-email --region us-east-1`

configure-cluster:
	ecs-cli configure --cluster ${CLUSTER_NAME} --region us-east-1 --config-name ${CONFIG_NAME}

cluster-down:
	ecs-cli down --cluster-config ${CONFIG_NAME}

cluster-up:
	ecs-cli up --keypair ${KEYPAIR} \
			   --capability-iam \
			   --size 1 \
			   --instance-type ${INSTANCE_TYPE} \
			   --cluster-config ${CONFIG_NAME} \
			   --subnets ${SUBNETS} \
			   --vpc ${VPC} \
			   --security-group ${SECURITY_GROUP} \
			   --force

run-task:
	cd deployment; ecs-cli compose up --create-log-groups --cluster-config ${CONFIG_NAME}

stop-task:
	cd deployment; ecs-cli compose down

	# or you can use docker directly
	# docker run \
	#   -v ${PWD}/catalog:/opt/planet/catalog \
	#   -v ${PWD}/cfg:/opt/planet/cfg daunnc/planet-downloader:latest python planet_download_tiff.py
##


all: docker-compose.yml

clean:
	rm -f docker-compose.local.yml
	rm -f docker-compose.deploy.yml

