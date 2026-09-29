-- Top source/destination pairs by bytes (after creating the flow-logs table).
SELECT srcaddr, dstaddr, SUM(bytes) AS total_bytes
FROM vpc_flow_logs
GROUP BY srcaddr, dstaddr
ORDER BY total_bytes DESC
LIMIT 25;
