## BI Connector for MongoDB

The BI Connector is a tool that allows you to use MongoDB as a data source in popular Business Intelligence (BI) and visualization applications, such as Tableau, Qlik, and Excel.

This Docker image provides an easy way to run the BI Connector in a containerized environment. The image is based on the official MongoDB image and includes all necessary dependencies and configuration to get the BI Connector up and running quickly.

## How to Use

1. Make sure you have Docker installed on your machine. You can follow the [installation instructions](https://docs.docker.com/engine/install/) on the Docker website to set it up.

2. Pull the latest version of the BI Connector Docker image from Docker Hub:

```
$ docker pull dasmeta/mongodb-bi-connector
```

3. Run the BI Connector container, replacing <mongodb_uri> with the URI of your MongoDB instance:
```
$ docker run -p 27000:27000 -e MONGODB_URI=<mongodb_uri> dasmeta/mongodb-bi-connector
```

4. Follow the instructions to set up and configure the BI Connector with your BI or visualization application.

## Additional Configuration
You can use the following environment variables to customize the behavior of the BI Connector Docker image:
- MONGODB_URI: The URI of your MongoDB instance. Required.
- BI_CONNECTOR_USER: The username to use when connecting to the BI Connector.
- BI_CONNECTOR_PASSWORD: The password to use when connecting to the BI Connector.

For more information on the BI Connector and its configuration options, please refer to the official documentation.

## Add a New Image
```shell
docker build dasmeta/mongodb-bi-connector:1.0.0 .
docker push dasmeta/mongodb-bi-connector:1.0.0
```
