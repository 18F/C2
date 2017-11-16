# Logging for ATO

Logs are available via Kibana here: [https://logs.fr.cloud.gov](https://logs.fr.cloud.gov)

- You almost always want to adjust the time-frame in the upper-right corner
- You can replace `c2-prod` below with `c2-staging` or `c2-dev`
- The application itself also tracks events: https://c2-dev.fr.cloud.gov/admin/ahoy_events

| Description                | Kibana Query                                      |
| -------------------------- | ------------------------------------------------- |
| Deployments                | `c2-prod AND "Recorded deployment"`               |
| Authorization checks       | `c2-prod AND "Authorization check"`               |
| Authentication checks      | `c2-prod AND "Authentication check"`              |
| Successful login events    | `c2-prod AND "Successful login"`                  |
| Unsuccessful login events  | `c2-prod AND "Unsuccessful login"`                |
| Object access *            | `c2-prod AND gsa18f_procurements`                 |
| Account management events  | `c2-prod AND ((versions AND User) OR user_roles)` |
| All administrator activity | `c2-prod AND admin`                               |
| Data deletions **          | `c2-prod AND DELETE`                              |
| Data access **             | `c2-prod AND SELECT`                              |
| Data changes **            | `c2-prod AND (UPDATE OR INSERT)`                  |
| Permission Changes         | `c2-prod AND user_roles AND INSERT`               |


\* For "object access" search by database table name.

\** For these queries, consider including a table name like `c2-prod AND SELECT AND proposals`


Some table names:
- `versions`
- `active_admin_comments`
- `attachments`
- `comments`
- `gsa18f_events`
- `gsa18f_procurements`
- `ncr_organizations`
- `ncr_orders`
- `proposal_roles`
- `proposals`
- `reports`
- `roles`
- `scheduled_reports`
- `steps`
- `tags`
- `user_roles`
- `users`

The `versions` table keeps an audit-trail of some models, use it with a model type like `c2-prod AND versions AND User`.
These models are versioned with Papertrail:
- `ApiToken`
- `Attachment`
- `Comment`
- `ClientDataMixin`
- `Proposal`
- `ProposalRole`
- `Step`
- `User`
- `UserDelegate`