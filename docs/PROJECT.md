# Project Writeup: AWS Hybrid Networking (Transit Gateway Hub-and-Spoke)

Why this exists, how it was built, why each choice, and the benefits. Also the interview talking-track. This maps closely to the AWS Advanced Networking Specialty domains.

## 1. The problem it solves

Once an organization has more than a couple of VPCs, full-mesh VPC peering stops scaling: the number of connections and route entries explodes, and there is no central place to inspect or control traffic. Teams also duplicate NAT gateways per VPC (expensive) and struggle to resolve DNS between AWS and on-prem. The standard answer is a Transit Gateway hub-and-spoke with centralized egress and hybrid DNS. This project builds that topology as reusable Terraform.

## 2. How it was built

Reusable modules wired together in envs/network:

- vpc: a spoke VPC with private subnets.
- egress: a shared VPC with public subnets, an internet gateway and a NAT gateway.
- tgw: the Transit Gateway with two route tables (spokes and egress), attachments, a default route from spokes to egress, and propagation of spoke CIDRs into the egress route table.
- dns-resolver: Route 53 Resolver inbound and outbound endpoints plus a forward rule to on-prem.
- flow-logs: VPC Flow Logs from every VPC to a hardened S3 bucket, with Athena queries for top talkers and rejected traffic.

The whole thing passes terraform validate.

## 3. Why each choice

- Transit Gateway over VPC peering: peering is not transitive and becomes a full mesh; TGW is a hub so adding a spoke is one attachment, not N new peerings. Route tables on the TGW give you segmentation.
- Separate spokes and egress route tables: spokes get a default route to the egress VPC but cannot route to each other unless you choose to allow it. That is segmentation by design, not by dozens of security-group rules.
- Centralized egress with one NAT: instead of a NAT gateway per VPC (each with an hourly and data cost), all spokes share one egress path. Cheaper and easier to inspect.
- Route 53 Resolver inbound and outbound: inbound lets on-prem resolve AWS-private names; outbound forwards on-prem zones to the on-prem resolver. This is how real hybrid DNS works.
- VPC Flow Logs to S3 plus Athena: logs are useless if you cannot query them. Athena turns flow logs into answers (who is talking to whom, what is being rejected).

## 4. Benefits

- Scales cleanly: a new environment is one VPC module plus one TGW attachment.
- Segmented by default: spoke-to-spoke traffic is blocked at the routing layer unless explicitly permitted.
- Cheaper egress: one NAT path instead of one per VPC.
- Working hybrid DNS in both directions.
- Traffic is observable and auditable through flow logs and Athena.

## 5. Interview talking points

- Why TGW over peering: transitivity, central control, and route-table segmentation; peering is non-transitive and O(n squared) to mesh.
- How spoke isolation works here: spokes associate to the spokes route table whose only route is a default to egress, so they never learn each other's routes.
- Inbound vs outbound Resolver endpoints: inbound = on-prem resolves AWS; outbound = AWS forwards to on-prem. You usually need both.
- Centralized vs distributed egress trade-offs: central is cheaper and easier to inspect but adds a cross-VPC hop and a shared failure domain.
- What to add next: a Site-to-Site VPN or Direct Connect with BGP to real on-prem, a central inspection VPC with a firewall, and TGW peering across regions.

## 6. How to run it

```bash
cd envs/network
terraform init
terraform apply   # set flow_log_bucket and on-prem values first
```

Tears down with terraform destroy. Note the NAT gateway and TGW attachments carry an hourly cost while running.