# This helm chart allows to create proxysql deployment setup in kubernetes https://docs.flagger.app/usage/metrics https://docs.flagger.app/usage/alerting 


## example
## NOTE: it is supposed that there is mysql server available at mysql.localhost with corresponding root/snM2sBBFbG user/pass
```yaml
proxysql:
  mysql:
    servers:
      - hostname: mysql.localhost
    users:
      - username: root
        password: snM2sBBFbG
```

## more examples in form of values.yaml files can be found in this repo /examples/proxysql/ folder