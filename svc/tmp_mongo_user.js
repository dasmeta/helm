if (!db.getUser('app_user')) { db.createUser({ user: 'app_user', pwd: 'app_secure_password', roles: [ {role: 'readWrite', db: 'directory'} ], passwordDigestor: 'server', }) };
