# Day 20 Project + AWS Focus

## Project Connection

Terraform includes Cloud SQL module. The services could use managed SQL for orders/cart/catalog data.

## GCP To AWS Mapping

Cloud SQL maps to RDS or Aurora.

## Project Question

How would you connect app services to RDS securely?

Answer:

```text
Place RDS in private subnets, allow inbound only from app security group on DB port, store credentials in Secrets Manager, use TLS if required, and monitor connections/CPU/storage.
```

