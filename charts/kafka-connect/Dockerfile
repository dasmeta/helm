# Use the official Confluent Kafka Connect base image
FROM confluentinc/cp-kafka-connect:7.2.2

# Install Aiven GCS Connector
RUN wget -O /tmp/aiven-kafka-connect-gcs-0.13.0.tar https://github.com/Aiven-Open/gcs-connector-for-apache-kafka/releases/download/v0.13.0/gcs-connector-for-apache-kafka-0.13.0.tar && \
  mkdir -p /usr/share/confluent-hub-components/aiven-kafka-connect-gcs && \
  tar -xvf /tmp/aiven-kafka-connect-gcs-0.13.0.tar --directory /usr/share/confluent-hub-components/aiven-kafka-connect-gcs

# Start Kafka Connect by default
CMD ["/etc/confluent/docker/run"]
