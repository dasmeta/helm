# MongoDB BI Connector Chart

This chart installs the [MongoDB BI Connector](https://docs.mongodb.com/bi-connector/current/) on your Kubernetes cluster. The BI Connector allows you to access MongoDB data using SQL, and can be used with business intelligence and analytics tools such as Tableau and Qlik.

## How to Use
1. Customize the default values in the values.yaml file.
2. To specify the URI of your MongoDB instance, find the mongodb.net.uri parameter in the values.yaml file and replace the placeholder URI with the real URI of your MongoDB instance. For example:
```
mongodb-bi-connector:
  mongosqldConfig: |-
    ...
    mongodb:
      net:
        uri: mongodb://user:password@host:port/database
        ssl:
          enabled: false
    ...
```
3. If you want to enable SSL when connecting to MongoDB, set the mongodb.net.ssl.enabled parameter to true.
4. To access the BI Connector, you can use a SQL client such as MySQL Workbench and connect to the BI Connector using the hostname and port specified in the net.bindIp and net.port parameters.
5. If you want to customize other parameters, such as the verbosity of the BI Connector logs or the refresh interval for the schema, you can do so by modifying the corresponding values in the values.yaml file.

## Installation
Install the chart by running the following command:
```
helm install my-release --namespace my-namespace dasmeta/mongodb-bi-connector -f values.yaml
```

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
