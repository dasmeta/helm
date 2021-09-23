# About
The mongo_backup_aws Docker image will provide you a container to backup and restore a Mongo database.
There is a possibility of the subsequent shipping to Amazon S3 Bucket.

# Usage
To backup a Mongo DB container you simply have to build Docker image from following source.

[Visit our GitHub repository](https://github.com/dasmeta/mongo_backup_aws.git)


    docker build -t image_name .
    
Please note the backup will be written to /backup by default, so you might want to mount that directory from your host.

## Useful example via docker compose 

```
mongo_backup:
  build:
    context: .
  container_name: mongodb_backup_migrate
  volumes:
    - ./backup:/backup
  environment:
    MONGODB_HOST: host
    MONGODB_PORT: port
    MONGO_INITDB_ROOT_USERNAME: user
    MONGO_INITDB_ROOT_PASSWORD: password
    AWS_ACCESS_KEY_ID: account_key_id
    AWS_SECRET_ACCESS_KEY: secret_access_key
    AWS_DEFAULT_REGION: region
    S3_BUCKET: s3_bucket_name
    MAX_BACKUPS: 30
    CRON_SCHEDULE: "3 * * * *"
    INIT_BACKUP: 'false'
    INIT_RESTORE: 'false'
```
### Environment variables

#### `Note: Some variables are required` 
| Environment Variables | Description |
| ------ | ------ |
|`MONGODB_HOST`|(required) This is gonna be Mongo database Host name|
|`MONGODB_PORT`|(Optional) Mongo database host Port|
|`MONGO_INITDB_ROOT_USERNAME`|(required) Mongo database username|
|`MONGO_INITDB_ROOT_PASSWORD`|(required) Mongo database password|
|`AWS_ACCESS_KEY_ID`|(required) Go to [Amazon Web Services](https://console.aws.amazon.com/) console and click on the name of your account (it is located in the top right corner of the console). Then, in the expanded drop-down list, select Security Credentials.|
|`AWS_SECRET_ACCESS_KEY`|(required) Go to [Amazon Web Services](https://console.aws.amazon.com/) console and click on the name of your account (it is located in the top right corner of the console). Then, in the expanded drop-down list, select Security Credentials.|
|`AWS_DEFAULT_REGION`|(required) Set aws default region. See [Amazon Web Services](https://console.aws.amazon.com/)|
|`S3_BUCKET`|(Optional) If bucket variable is set the backups will be shipped/restored to/from Amazon S3 Bucket. `Otherwise It will be saved locally.`|
|`MAX_BACKUPS`| (Optional) Count of maximum backups on local machine. `Necessary if S3_BUCKET variable is not set. Default value is 30`|
|`CRON_SCHEDULE`| Please visit [CRON SCHEDULE](https://crontab.guru/) to choose your specific schedule time.|
|`INIT_BACKUP`|(Optional) To make mongo backup on container startup mark value `true`. `Default is: 'false'`. If `S3_BUCKET` is set, the latest backup will be shipped to bucket. Otherwise, database will be saved on local volume.|
|`INIT_RESTORE`|(Optional) To make mongo restore on container startup mark value `true`. `Default is: 'false'`. If `S3_BUCKET` is set, the latest backup will be downloaded from bucket. Otherwise, database will be restored from the local volume.|

It would be better to write environment variables in `.env` file.

## How to helm
`helm upgrade --install mongodb-backup-aws .`