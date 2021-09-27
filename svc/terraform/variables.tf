variable volume-size {
  type        = string
  default     = "10Gi"
  description = "Size of the backup volume storage. Should be enough big to fit backup files."
}

variable volume-storageClass {
  type        = string
  default     = "gp2"
  description = "Volume strage class AWS will be claimed for. No need for fast storage as this will be used once during backup."
}

variable mongodb-host {
  type        = string
  description = "Mongodb host name backup script will be taking data from."
}

variable s3-bucket {
  type        = string
  description = "The bucket backups will be stored."
}

variable schedule {
  type        = string
  default     = "3 0 * * *"
  description = "Backup schedule, in crojob format. E.g. '3 0 * * *'"
}

variable backup-on-start {
  type        = string
  default     = true
  description = "If enabled scripts will do backup right on the start and then according to the schedule."
}

variable aws-access-key-id {
  type        = string
  description = "AWS Access Key ID script will need to push backups into the S3 bucket."
  sensitive = true
}

variable aws-secret-access-key {
  type        = string
  description = "AWS Secret Access Key script will need to push backups into the S3 bucket."
  sensitive = true
}

variable mongodb-username {
  type        = string
  description = "Mongodb user name script will need to pull data from mongodb."
  sensitive = true
}

variable mongodb-password {
  type        = string
  description = "Mongodb user password script will need to pull data from mongodb."
  sensitive = true
}
