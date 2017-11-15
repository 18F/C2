# Logging for ATO

Logs are available via Kibana here: [https://logs.fr.cloud.gov](https://logs.fr.cloud.gov)

Tip: you almost always want to adjust the time-frame in the upper-right corner.

| Description               | Kibana Query                           |
| ------------------------- | -------------------------------------- |
| Deployments               | `"c2-prod" AND "Recorded deployment"`  |
| Authorization checks      | `"c2-prod" AND "Authorization check"`  |
| Authentication checks     | `"c2-prod" AND "Authentication check"` |
| Successful login events   | `"c2-prod" AND "Successful login"`     |
| Unsuccessful login events | `"c2-prod" AND "Unsuccessful login"`   |