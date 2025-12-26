# PgCat Helm Chart

This Helm chart allows you to deploy PgCat (PostgreSQL proxy and connection pooler) in Kubernetes with read/write splitting capabilities.

## Overview

PgCat is a PostgreSQL proxy that provides:
- Connection pooling
- Read/write splitting between primary and replica servers
- SQL-aware routing
- Load balancing
- Health checks and automatic failover
- Sharding support

For full configuration documentation, see: https://github.com/postgresml/pgcat/blob/main/CONFIG.md

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PostgreSQL cluster with primary and replica servers

## Installation

```bash
helm install my-pgcat ./charts/pgcat -f values.yaml
```

## Configuration

### Basic Example

The following example shows a minimal configuration with read/write splitting:

```yaml
pgcat:
  podAnnotations:
    app.config/checksum: v1
  volumes:
    - name: pgcat-config
      mountPath: /etc/pgcat.toml
      subPath: pgcat.toml
      readOnly: true
      configMap:
        name: pgcat
  envFrom:
    secret: pgcat

  app:
    general:
      port: 6432 # Default PgCat port (same as PgBouncer)
      admin_username: "admin_user"
      admin_password: "admin_pass"

    pools:
      myapp:
        pool_mode: "transaction"
        load_balancing_mode: "random"
        default_role: "any" # Routes to any server (primary or replica)
        query_parser_enabled: true # Enable read/write splitting
        primary_reads_enabled: true # Allow reads on primary
        
        users:
          - username: "app_user"
            password: "app_password"
            pool_size: 9
        
        shards:
          - database: "myapp"
            servers:
              # Primary server - format: [host, port, role]
              - ["postgres-primary.example.com", 5432, "primary"]
              # Replica servers
              - ["postgres-replica-1.example.com", 5432, "replica"]
              - ["postgres-replica-2.example.com", 5432, "replica"]
```

### Advanced Example with Multiple Pools

```yaml
pgcat:
  podAnnotations:
    app.config/checksum: v1
  volumes:
    - name: pgcat-config
      mountPath: /etc/pgcat.toml
      subPath: pgcat.toml
      readOnly: true
      configMap:
        name: pgcat
  envFrom:
    secret: pgcat

  app:
    general:
      port: 6432
      enable_prometheus_exporter: true
      prometheus_exporter_port: 9930
      server_tls: true # Enable TLS for server connections
      verify_server_certificate: true
      admin_username: "admin_user"
      admin_password: "admin_pass"

    pools:
      myapp:
        pool_mode: "transaction"
        load_balancing_mode: "loc" # Least outstanding connections
        default_role: "any"
        query_parser_enabled: true
        primary_reads_enabled: true
        checkout_failure_limit: 3
        
        users:
          - username: "app_user"
            password: "app_password"
            pool_size: 25
            min_pool_size: 5
            statement_timeout: 30000
        
        shards:
          - database: "myapp"
            servers:
              - ["postgres-primary.example.com", 5432, "primary"]
              - ["postgres-replica-1.example.com", 5432, "replica"]
              - ["postgres-replica-2.example.com", 5432, "replica"]
      
      analytics:
        pool_mode: "session"
        load_balancing_mode: "random"
        default_role: "replica" # Only use replicas by default
        query_parser_enabled: true
        
        users:
          - username: "analytics_user"
            password: "analytics_password"
            pool_size: 15
        
        shards:
          - database: "analytics"
            servers:
              - ["analytics-primary.example.com", 5432, "primary"]
              - ["analytics-replica.example.com", 5432, "replica"]
```

### TLS Configuration

To enable TLS for client connections (clients -> pgcat):

```yaml
pgcat:
  volumes:
    - name: pgcat-config
      mountPath: /etc/pgcat.toml
      subPath: pgcat.toml
      readOnly: true
      configMap:
        name: pgcat
    - name: pgcat-tls
      mountPath: /etc/pgcat/tls
      readOnly: true
      configMap:
        name: pgcat-tls

  app:
    general:
      tls_certificate: "/etc/pgcat/tls/client-cert.pem"
      tls_private_key: "/etc/pgcat/tls/client-key.pem"
      server_tls: true # Enable TLS for upstream connections
      verify_server_certificate: true

    tls:
      client_cert: |
        -----BEGIN CERTIFICATE-----
        ... your certificate content ...
        -----END CERTIFICATE-----
      client_key: |
        -----BEGIN PRIVATE KEY-----
        ... your private key content ...
        -----END PRIVATE KEY-----
```

## Key Configuration Options

### General Section

- `host`: IP to run on (default: "0.0.0.0")
- `port`: Port to run on (default: 6432, same as PgBouncer)
- `enable_prometheus_exporter`: Enable Prometheus metrics (default: true)
- `prometheus_exporter_port`: Prometheus exporter port (default: 9930)
- `server_tls`: Use TLS for server connections (default: false)
- `verify_server_certificate`: Verify server certificate (default: false)
- `tls_certificate`: Path to TLS certificate for client connections
- `tls_private_key`: Path to TLS private key for client connections
- `admin_username`: Admin user for administrative database access
- `admin_password`: Admin password

### Pools Configuration

Pools are defined as a map where keys are pool names. Each pool can have:

- `pool_mode`: Pool mode - `session` or `transaction` (default: "transaction")
- `load_balancing_mode`: `random` or `loc` (least outstanding connections)
- `default_role`: Default routing - `any`, `replica`, or `primary` (default: "any")
- `query_parser_enabled`: Enable SQL parsing for read/write splitting (default: true)
- `primary_reads_enabled`: Allow reads on primary (default: true)
- `users`: Array of user configurations
- `shards`: Array of shard configurations

### Users Configuration

Each user in a pool can have:

- `username`: PostgreSQL username
- `password`: PostgreSQL password
- `server_username`: Optional different username for server connections
- `server_password`: Optional different password for server connections
- `pool_size`: Maximum server connections for this user (default: 9)
- `min_pool_size`: Minimum idle connections (default: 0)
- `statement_timeout`: Maximum query duration in milliseconds (0 = disabled)

### Shards Configuration

Each shard defines:

- `database`: Database name
- `servers`: Array of servers, each as `[host, port, role]`
  - `role` can be `"primary"` or `"replica"`
- `mirrors`: Optional array of mirrors for failover

## Read/Write Splitting

When `query_parser_enabled` is `true`, PgCat automatically routes:

- **Read queries (SELECT)** → Replica servers (or primary if `primary_reads_enabled: true`)
- **Write queries (INSERT, UPDATE, DELETE, etc.)** → Primary server
- **SELECT ... FOR UPDATE** → Primary server
- **SELECT ... FOR SHARE** → Primary server
- **Transaction-aware**: All queries within a transaction go to the same server (primary)

## Important Notes

- This Helm chart uses the `base` chart as a dependency, similar to the `proxysql` chart
- Configuration changes require updating `podAnnotations.app.config/checksum` to trigger a pod restart
- The chart supports Prometheus metrics scraping via PodMonitor or ServiceMonitor
- TLS certificates can be provided via ConfigMap for secure connections
- All sensitive data (passwords) should be managed through Kubernetes Secrets
- Default port is 6432 (same as PgBouncer), not 5432
- PgCat supports automatic config reloading via `autoreload` setting

## Examples

More examples can be found in the `/examples/pgcat/` folder.

## Troubleshooting

- Check pod logs: `kubectl logs <pod-name>`
- Verify configuration: `kubectl get configmap <release-name> -o yaml`
- Test connectivity: `kubectl exec -it <pod-name> -- psql -h localhost -p 6432 -U <user> -d <database>`
- Access admin interface: Connect to the admin database using `admin_username` and `admin_password`

## References

- PgCat GitHub: https://github.com/postgresml/pgcat
- Configuration Documentation: https://github.com/postgresml/pgcat/blob/main/CONFIG.md
