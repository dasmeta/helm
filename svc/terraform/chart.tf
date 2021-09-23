module "release" {
  source  = "terraform-module/release/helm"
  version = "2.6.0"

  namespace  = "default"
  repository =  "https://charts.helm.sh/stable"

  app = {
    name          = "mongodb-backup-aws"
    version       = "0.1.0"
    chart         = "${path.module}/../helm/mongodb-backup-aws"
    force_update  = true
    wait          = true
    recreate_pods = false
    deploy        = 1
  }

  values = []

  set = [
    {
      name  = "config.MONGODB_HOST"
      value = var.mongodb-host
    },
    {
      name  = "config.S3_BUCKET"
      value = var.s3-bucket
    },
    {
      name  = "config.CRON_TIME"
      value = var.schedule
    },
    {
      name  = "config.INIT_BACKUP"
      value = var.backup-on-start
    },
  ]

  set_sensitive = [
    {
      path  = "config.AWS_ACCESS_KEY_ID"
      value = var.aws-access-key-id
    },
    {
      path  = "config.AWS_SECRET_ACCESS_KEY"
      value = var.aws-secret-access-key
    },
    {
      path  = "config.MONGO_INITDB_ROOT_USERNAME"
      value = var.mongodb-username
    },
    {
      path  = "config.MONGO_INITDB_ROOT_PASSWORD"
      value = var.mongodb-password
    },
  ]
}
