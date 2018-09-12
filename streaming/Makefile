CONFIG_NAME := osm-stat-stream-config
CLUSTER_NAME := osm-stat-stream-cluster

INSTANCE_TYPE := m4.large
INSTANCE_ROLE := ???
KEYPAIR := ???
SUBNETS := ???
VPC := ???
SECURITY_GROUP := ???
REPO_NAME := osm-analytics

LOCAL_IMG := osm_analytics:latest

AUGDIFF_START := 1
AUGDIFF_SOURCE := s3://mojodna-temp/augdiffs/

CHANGESET_START := 1
CHANGESET_SOURCE := https://planet.osm.org/replication/changesets/

CHANGE_START := 1
CHANGE_SOURCE := https://planet.osm.org/replication/minute/

AWS_LOG_GROUP := osm-stats-stream
AWS_REGION := us-east-1
DB_URI := ???
DB_USER := ???
DB_PASS := ???

REPO_URI=$(shell jq .repository.repositoryUri repository)


#########
# LOCAL #
#########
docker-compose.local.yml:
	export STREAM_REPO=${STREAM_REPO}; \
	export AUGDIFF_SOURCE=${AUGDIFF_SOURCE}; \
	export CHANGESET_SOURCE=${CHANGESET_SOURCE}; \
	export CHANGE_SOURCE=${CHANGE_SOURCE}; \
	export AUGDIFF_START=${AUGDIFF_START}; \
	export CHANGESET_START=${CHANGESET_START}; \
	export CHANGE_START=${CHANGE_START}; \
		../expand.sh docker-compose.local.yml.tpl > docker-compose.local.yml

start-local: docker-compose.local.yml
	docker-compose -f docker-compose.local.yml up

stop-local:
	docker-compose -f docker-compose.local.yml down


#########
#  AWS  #
#########

repository:
	aws ecr create-repository --repository-name ${REPO_NAME} > repository

login-aws-registry: repository
	eval `aws ecr get-login --no-include-email --region us-east-1`

tag-image: repository login-aws-registry
	docker tag ${LOCAL_IMG} $(call REPO_URI):latest

push-image: repository login-aws-registry tag-image
	docker push $(call REPO_URI):latest

docker-compose.deploy.yml: repository
	export STREAM_REPO=$(call REPO_URI); \
	export AWS_LOG_GROUP=${AWS_LOG_GROUP}; \
	export AWS_REGION=${AWS_REGION}; \
	export AUGDIFF_START=${AUGDIFF_START}; \
	export CHANGESET_START=${CHANGESET_START}; \
	export DB_URI=${DB_URI}; \
	export DB_USER=${DB_USER}; \
	export DB_PASS=${DB_PASS}; \
		../expand.sh docker-compose.deploy.yml.tpl > docker-compose.deploy.yml

configure-cluster:
	ecs-cli configure --cluster ${CLUSTER_NAME} --region us-east-1 --config-name ${CONFIG_NAME}

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

cluster-down:
	ecs-cli down --cluster-config ${CONFIG_NAME}

start-service:
	ecs-cli compose up --create-log-groups --cluster-config ${CONFIG_NAME}

stop-service:
	ecs-cli compose down


#########
#  ALL  #
#########
clean:
	docker-compose -f docker-compose.local.yml down || echo Local cluster already down
	aws ecr delete-repository --repository-name ${REPO_NAME}
	rm -f repository
	rm -f docker-compose.local.yml
	rm -f docker-compose.deploy.yml

