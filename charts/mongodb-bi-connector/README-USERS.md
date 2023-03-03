# bi-connector user guide

## how to connect from mysql cli
`mysql --enable-cleartext-plugin -h mongodb-bi-connector -P 3307 -u <user> -p <password>`

## how to connect from python script using sqlalchemy
To get SQL alchemy working with clear text auth you need to export this variable first.
`export LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1`.

You will need to install mongobi dialect for sqlalchemy
`pip install sqlalchemy-mongobi`.

The this script will pull data from test.user table.
```python
import sqlalchemy
import os
import json

mongobi_host = "0.0.0.0"
mongobi_username = "root"
mongobi_password = "password"
mongobi_port = 3307
mongobi_db = "test"

mongobi_uri = "mongobi://{}:{}@{}:{}/{}".format(mongobi_username, mongobi_password, mongobi_host, mongobi_port, mongobi_db)

engine = sqlalchemy.create_engine(mongobi_uri)

with engine.connect() as conn:
    result = conn.execute("select * from user")
    print('------------')
    print(json.dumps([dict(zip(row.keys(), row)) for row in result], indent=2))

# mongobi://root:password@mongodb-bi-connector:3307/test
```

Happy coding!
