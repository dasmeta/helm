# ProxySQL Helm Chart

This Helm chart allows you to deploy ProxySQL (high-performance MySQL and PostgreSQL proxy) in Kubernetes with connection pooling, query routing, and read/write splitting capabilities.

## Overview

ProxySQL is a high-performance proxy for MySQL and PostgreSQL that provides:

- **Connection pooling** - Efficient connection management and reuse
- **Read/write splitting** - Automatic routing of reads to replicas and writes to primary
- **Query routing** - SQL-aware routing based on query patterns
- **Load balancing** - Distribute load across multiple backend servers
- **Health checks and failover** - Automatic detection and failover of unhealthy servers
- **Query caching** - Cache frequently executed queries
- **AWS Aurora integration** - Native support for Aurora cluster discovery and management

### Database Support

- **MySQL/MariaDB** - Full production support
- **PostgreSQL** - Initial support (ProxySQL 3.0+), **not yet stable** ⚠️

> **Note**: PostgreSQL support is in its initial phase and may have limitations. Use with caution in production environments.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.7.1+
- MySQL/MariaDB or PostgreSQL cluster with primary and replica servers
- ProxySQL 3.0.4+ (for PostgreSQL support)

## Installation

### Add the Helm repository

```bash
helm repo add dasmeta https://dasmeta.github.io/helm
helm repo update
```

### Install with default values

```bash
helm install my-proxysql dasmeta/proxysql --version 1.0.1
```

### Install with custom values

```bash
helm install my-proxysql dasmeta/proxysql --version 1.0.1 -f my-values.yaml
```

### Upgrade an existing release

```bash
helm upgrade my-proxysql dasmeta/proxysql --version 1.0.1 -f my-values.yaml
```

## Configuration

### Basic MySQL Example

The following example shows a minimal MySQL configuration:

```yaml
proxysql:
  podAnnotations:
    app.config/checksum: v1

  app:
    databaseType: "mysql"  # Select database type: "mysql" or "pgsql"

    servers:
      - is_writer: true
        hostname: mysql-primary.example.com
        port: 3306
      - is_writer: false
        hostname: mysql-replica.example.com
        port: 3306

    users:
      - username: app_user
        password: app_password
        read_only: false

    readWriteSplit: true  # Enable automatic read/write splitting
```

### Basic PostgreSQL Example

The following example shows a minimal PostgreSQL configuration:

```yaml
proxysql:
  podAnnotations:
    app.config/checksum: v1

  app:
    databaseType: "pgsql"  # Select database type: "mysql" or "pgsql"

    pgsql:
      ports:
        - 6133  # ProxySQL listening port for PostgreSQL clients (default: 6132, example uses 6133)

    servers:
      - is_writer: true
        hostname: postgres-primary.example.com
        port: 5432
      - is_writer: false
        hostname: postgres-replica.example.com
        port: 5432

    users:
      - username: app_user
        password: app_password
        read_only: false

    readWriteSplit: true  # Enable automatic read/write splitting
```

> **Warning**: PostgreSQL support is in initial phase and not yet stable. Test thoroughly before production use.

### Advanced Configuration

For more complex configurations, see the examples in the `/examples/proxysql/` folder:

- `proxysql-basic.values.yaml` - Basic setup
- `proxysql-three-backends.values.yaml` - Multiple backend servers
- `proxysql-advanced.values.yaml` - Advanced routing rules and caching
- `proxysql-with-aws-aurora.values.yaml` - AWS Aurora integration

## Key Configuration Parameters

### Database Type Selection

```yaml
proxysql:
  app:
    databaseType: "mysql"  # or "pgsql" for PostgreSQL
```

### Service Ports

The service port should match your database type and the first port in the `ports` array:

- **MySQL**: Default port `3306`
- **PostgreSQL**: Default port `6132` (ProxySQL default) or `5432` (standard PostgreSQL port)

```yaml
proxysql:
  service:
    port: 3306  # For MySQL, use 5432 or 6132 for PostgreSQL
  containerPort: 3306  # For MySQL, use 5432 or 6132 for PostgreSQL
  app:
    mysql:
      ports:
        - 3306  # Must match service.port
    # OR for PostgreSQL:
    pgsql:
      ports:
        - 6133  # Must match service.port (default ProxySQL pgsql port is 6132)
```

### Backend Servers

Configure your database servers:

```yaml
proxysql:
  app:
    servers:
      - is_writer: true  # Primary/writer server
        hostname: db-primary.example.com
        port: 3306
        weight: 1000
        max_connections: 1000
        use_ssl: 0
      - is_writer: false  # Replica/reader server
        hostname: db-replica.example.com
        port: 3306
        weight: 1000
        max_replication_lag: 60
```

### Database Users

Configure users that will connect through ProxySQL:

```yaml
proxysql:
  app:
    users:
      - username: app_user
        password: app_password
        max_connections: 1000
        read_only: false  # false = can write, true = read-only
        transaction_persistent: 1
```

### Read/Write Splitting

Enable automatic read/write splitting:

```yaml
proxysql:
  app:
    readWriteSplit: true  # Routes SELECT to readers, writes to writers
    writerHostgroup: 0  # Hostgroup ID for writers
    readerHostgroup: 1  # Hostgroup ID for readers
```

### Custom Query Rules

Define custom routing and caching rules:

```yaml
proxysql:
  app:
    rules:
      - match_digest: "^SELECT .* FROM users WHERE id ="
        destination_hostgroup: 1  # Route to reader
        cache_ttl: 60000  # Cache for 60 seconds
        apply: 1
        active: 1
      - match_digest: "^UPDATE .* SET"
        destination_hostgroup: 0  # Route to writer
        apply: 1
        active: 1
```

### AWS Aurora Integration

For AWS Aurora clusters:

```yaml
proxysql:
  app:
    awsAurora:
      enabled: true
      domain_name: ".abcde.us-east-1.rds.amazonaws.com"
      active: 1
      aurora_port: 3306
      max_lag_ms: 600000
```

## Important Notes

### Version Compatibility

- **Chart version 1.0.1** uses **ProxySQL 3.0.4**
- PostgreSQL support requires ProxySQL 3.0+
- Breaking changes were introduced in chart version 0.2.0

### Configuration Structure

All ProxySQL-specific configurations are under `proxysql.app.*`:

- `proxysql.app.mysql.*` - MySQL-specific settings
- `proxysql.app.pgsql.*` - PostgreSQL-specific settings (initial support)
- `proxysql.app.servers` - Backend server definitions
- `proxysql.app.users` - Database user definitions
- `proxysql.app.rules` - Custom query routing rules

### Terraform Integration

This Helm chart can be used standalone or through the Terraform module:

```hcl
module "proxysql" {
  source = "dasmeta/rds/aws//modules/proxysql"
  # ... configuration
}
```

### PostgreSQL Support Status

⚠️ **PostgreSQL support is in initial phase and not yet stable.**

- Requires ProxySQL 3.0.4+
- Some features may have limitations
- Monitor variables are simplified compared to MySQL (only basic monitoring variables are supported)
- Configuration uses `pgsql` (not `postgresql`) as the database type value
- Default ProxySQL listening port for PostgreSQL is `6132` (configurable via `pgsql.ports`)
- Test thoroughly in non-production environments first

### Admin Interface

The admin interface uses a unified `admin_interfaces` configuration (default port 6032) and supports both MySQL and PostgreSQL protocols. The admin interface is accessible via MySQL protocol regardless of the backend database type.

### Health Checks

Health check probes use the admin interface (port 6032) for both MySQL and PostgreSQL configurations. The admin interface always uses MySQL protocol for administrative access.

### SSL/TLS Support

To enable SSL connections to backend servers:

```yaml
proxysql:
  app:
    mysql:  # or pgsql for PostgreSQL
      ssl_p2s_ca: |  # CA certificate content
        -----BEGIN CERTIFICATE-----
        ...
        -----END CERTIFICATE-----
```

**Note for PostgreSQL**: When SSL is enabled for PostgreSQL, ProxySQL automatically enables event logging to stdout for better debugging and monitoring.

## Examples

Comprehensive examples are available in the `/examples/proxysql/` directory:

- `proxysql-basic.values.yaml` - Minimal setup
- `proxysql-three-backends.values.yaml` - Multiple backends with read/write splitting
- `proxysql-advanced.values.yaml` - Advanced routing and caching
- `proxysql-minimal-three-backends.values.yaml` - Minimal multi-backend setup
- `proxysql-with-aws-aurora.values.yaml` - AWS Aurora cluster integration

## Troubleshooting

### View ProxySQL logs

```bash
kubectl logs -l app.kubernetes.io/name=proxysql
```

### Access ProxySQL admin interface

```bash
# Port forward to admin interface
kubectl port-forward svc/my-proxysql 6032:6032

# Connect using MySQL client
mysql -h 127.0.0.1 -P 6032 -u admin -p
```

### Check configuration

```bash
# View rendered ConfigMap
kubectl get configmap my-proxysql -o yaml
```

## Resources

- [ProxySQL Documentation](https://proxysql.com/documentation/)
- [ProxySQL MySQL Variables](https://proxysql.com/documentation/global-variables/mysql-variables/)
- [ProxySQL PostgreSQL Variables](https://proxysql.com/documentation/global-variables/pgsql-variables/)
- [ProxySQL GitHub](https://github.com/sysown/proxysql)

## License

See LICENSE file in the repository root.
