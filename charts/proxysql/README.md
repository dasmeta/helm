# This helm chart allows to create proxysql deployment setup in kubernetes https://docs.flagger.app/usage/metrics https://docs.flagger.app/usage/alerting 


## example
## NOTE: it is supposed that there is mysql server available at mysql.localhost with corresponding root/snM2sBBFbG user/pass
```yaml
proxysql:
  app:
    servers:
      - hostname: mysql.localhost
    users:
      - username: root
        password: snM2sBBFbG
```

## more examples in form of values.yaml files can be found in this repo /examples/proxysql/ folder

## important notes
- this helm chart can be used on its own but it is handy to used through terraform module "dasmeta/rds/aws//modules/proxysql"
- the new 0.2.0 version brings several improvements and breaking changes in terms of config variable names and placement in values.yaml, please check new variables placement and namings before upgrading an existing setup:
  - support of aurora integration added, check corresponding example in [/examples/proxysql/proxysql-with-aws-aurora.values.yaml](/examples/proxysql/proxysql-with-aws-aurora.values.yaml)
  - all proxysql app specific configs are now placed under proxysql.app.*, this is for distinction of base chart configs from proxysql app specific settings
  - servers/users/readWriteSplit/rules are now on proxysql.app.* level instead of being sub-config of mysql
  - proxysql.app.mysql.* config items all got changed from camelCase to snake_case and it allows to add additional configs that not listed in default values.yaml
  - ability to set backend servers certificate added through passing cert file content to proxysql.app.mysql.ssl_p2s_ca config item