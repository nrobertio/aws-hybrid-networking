-- Rejected traffic, useful for spotting misconfigured security groups or scans.
SELECT srcaddr, dstaddr, dstport, COUNT(*) AS rejects
FROM vpc_flow_logs
WHERE action = 'REJECT'
GROUP BY srcaddr, dstaddr, dstport
ORDER BY rejects DESC
LIMIT 25;
