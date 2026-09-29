# AWS Hybrid Networking (Transit Gateway Hub-and-Spoke)

Terraform for a multi-VPC **Transit Gateway** hub-and-spoke with a shared **egress VPC**, **Route 53 Resolver** for hybrid DNS, **VPC interface endpoints** to keep traffic off the internet, and **VPC Flow Logs** captured to S3 with Athena queries to analyse them. A **Site-to-Site VPN** with BGP is included (commented) to represent the on-prem link.

> Maintained by [nrobertio](https://github.com/nrobertio). A generic, public version of the multi-account AWS networking I design day to day: Transit Gateway, hybrid DNS, segmentation and flow-log analysis. Maps closely to the AWS Advanced Networking Specialty domains.

## What this demonstrates

- **Transit Gateway hub-and-spoke**: multiple spoke VPCs attached to a central TGW with route-table segmentation.
- **Centralized egress**: spokes reach the internet through a shared egress VPC and NAT, instead of a NAT per VPC.
- **Hybrid DNS**: Route 53 Resolver inbound and outbound endpoints for name resolution to and from on-prem.
- **Private connectivity**: interface VPC endpoints (SSM, ECR, etc.) so workloads avoid the public internet.
- **Observability**: VPC Flow Logs to S3 plus Athena queries (top talkers, rejected traffic).

## Layout

```
modules/
  vpc/             reusable spoke VPC
  tgw/             Transit Gateway + route tables + attachments
  egress/          shared egress VPC with NAT
  dns-resolver/    Route 53 Resolver inbound and outbound endpoints
  flow-logs/       VPC Flow Logs to S3
envs/network/      wires the modules into a hub-and-spoke topology
athena/            flow-log analysis queries
docs/PROJECT.md    why, how, benefits, interview notes
```

## Usage

```bash
cd envs/network && terraform init && terraform apply
```

## License

MIT. See [LICENSE](LICENSE).
