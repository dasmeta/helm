# MongoDB BI Connector Chart

This chart installs the [MongoDB BI Connector](https://docs.mongodb.com/bi-connector/current/) on your Kubernetes cluster. The BI Connector allows you to access MongoDB data using SQL, and can be used with business intelligence and analytics tools such as Tableau and Qlik.
The BI Connector includes a ConfigMap that stores the configuration for the BI Connector. It can be customized easily.

## How to Use
1. Customize the default values in the values.yaml file.
2. Add the dependency for this chart in the Chart.yaml file:
```
...
dependencies:
- name: mongodb-bi-connector
  version: 1.0.1
  repository: https://dasmeta.github.io/helm
...
```
3. To specify the URI of your MongoDB instance, find the mongodb.net.uri parameter in the values.yaml file and replace the placeholder URI with the real URI of your MongoDB instance. For example:
```
mongodb-bi-connector:
  ...
  mongosqldConfig:
    mongodb:
      net:
        uri: mongodb://user:password@host:port/database
        ssl:
          enabled: false
  ...
```
4. To access the BI Connector, you can use a SQL client such as MySQL Workbench and connect to the BI Connector using the hostname and port specified in the net.bindIp and net.port parameters.
5. If you want to customize other parameters, such as the verbosity of the BI Connector logs or the refresh interval for the schema, you can do so by modifying the corresponding values in the values.yaml file(the same way explained in 3). In general, the `mongosqldConfig` values will be merged with the default `mongosqldConfigDefault` described in default values for the chart. This means that any values you specify in `mongosqldConfig` will overwrite the corresponding values in `mongosqldConfigDefault`.
6. As it uses `base` chart as a dependency, you can customize `base` configurations as well: For example:
```
mongodb-bi-connector:
  ...
  base:
    replicaCount: 2
    env: stage
  ...
```
Complete usage example will be like:
```
mongodb-bi-connector:
  base:
    replicaCount: 2
    env: stage

  mongosqldConfig:
    net:
      bindIp: "0.0.0.0"
      port: 2000
      ssl:
        mode: "enabled"
```

## Installation
Install the chart by running the following command:
```
helm install my-release --namespace my-namespace dasmeta/mongodb-bi-connector -f values.yaml
```
You can customize the installation by specifying your own values for the parameters in the values.yaml file, or by using the --set flag to override individual values at install time.

For example, to override the mongosqldConfig values at install time:
```
helm install my-release --namespace my-namespace dasmeta/mongodb-bi-connector --set mongodb-bi-connector.mongosqldConfig.net.port=3308,mongodb-bi-connector.mongosqldConfig.net.ssl.mode=enabled
```

## Dockerfile
The BI Connector is provided as a Docker image hosted on Docker Hub at [dasmeta/mongodb-bi-connector](https://hub.docker.com/r/dasmeta/mongodb-bi-connector).
Also, you can find the image content in our [GitHub page](https://github.com/dasmeta/docker-images/tree/master/mongodb-bi-connector).

## Configuration

The following table lists the configurable parameters of the MongoDB BI Connector chart and their default values.

| Parameter                    | Description                                                                                                               | Default             |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------- | ------------------- |
| `net.bindIp`                 | The IP address that the BI Connector should bind to.                                                                      | `0.0.0.0`           |
| `net.port`                   | The port that the BI Connector should listen on.                                                                          | `3307`              |
| `net.ssl.mode`               | The SSL mode to use for the BI Connector. Possible values are `disabled`, `allowSSL`, and `preferSSL`.                    | `disabled`          |
| `mongodb.net.uri`            | The URI of the MongoDB instance to connect to.                                                                            | `mongodb://mongodb` |
| `mongodb.net.ssl.enabled`    | Whether to use SSL when connecting to the MongoDB instance.                                                               | `false`             |
| `systemLog.quiet`            | Whether to enable quiet mode. When quiet mode is enabled, the BI Connector will not log to the console.                   | `false`             |
| `systemLog.verbosity`        | The verbosity of the BI Connector logs. A higher verbosity will result in more log output.                                | `1`                 |
| `systemLog.logRotate`        | The log rotate mode to use. Possible values are `rename` and `reopen`.                                                    | `rename`            |
| `schema.refreshIntervalSecs` | The interval, in seconds, at which the BI Connector should refresh the schema. A value of `0` disables automatic refresh. | `0`                 |
| `schema.stored.mode`         | The mode to use for stored schemas. Possible values are `custom`, `all`, and `none`.                                      | `custom`            |
| `schema.stored.source`       | The source for the stored schema. This should be set to `mongosqld_data` if `schema.stored.mode` is set to `custom`.      | `mongosqld_data`    |
| `schema.stored.name`         | The name of the stored schema. This should be set if `schema.stored.mode` is set to `custom`.                             | `mySchema`          |
| `schema.sample.size`         | The number of documents to sample when generating the schema. This should be set if `schema.stored.mode                   |
