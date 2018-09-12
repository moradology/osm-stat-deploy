version: '3.0'
services:
  augdiff-stream:
    image: ${AUGDIFF_STREAM_REPO}:latest
    command: >
      /spark/bin/spark-submit --class osmesa.analytics.oneoffs.ChangeStreamProcessor /opt/osmesa-analytics.jar
      --augmented-diff-source ${AUGDIFF_SOURCE}
      --start-sequence ${AUGDIFF_START}
      --database-uri ${DB_URI}
      --database-user ${DB_USER}
      --database-pass ${DB_PASS}
    deploy:
      restart_policy:
        condition: on-failure
        delay: 1s
        max_attempts: 10
        window: 120s
    logging:
      driver: awslogs
      options:
        awslogs-group: ${AWS_LOG_GROUP}
        awslogs-region: ${AWS_REGION}
        awslogs-stream-prefix: augdiff
  changeset-stream:
    image: ${CHANGESET_STREAM_REPO}:latest
    command: >
      /spark/bin/spark-submit --class osmesa.analytics.oneoffs.ChangeStreamProcessor /opt/osmesa-analytics.jar
      --change-source https://planet.osm.org/replication/minute/
      --start-sequence ${CHANGESET_START}
      --database-uri ${DB_URI}
      --database-user ${DB_USER}
      --database-pass ${DB_PASS}
    deploy:
      restart_policy:
        condition: on-failure
        delay: 1s
        max_attempts: 10
        window: 120s
    logging:
      driver: awslogs
      options:
        awslogs-group: ${AWS_LOG_GROUP}
        awslogs-region: ${AWS_REGION}
        awslogs-stream-prefix: changeset
