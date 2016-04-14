# API

***If you are running the server and want to enable the API, set the environment variable `API_ENABLED=true`.***

The API design is evolving. Backwards-incompatible changes will result in a version change.

The lastest version is *v2*.

## Schemas

* All decimals are strings ([more info](https://github.com/rails-api/active_model_serializers/issues/202))
* All times are in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format

### Proposal

Each proposal object is composed of a few attributes and some child objects.

### Attributes

Attribute | Type | Note
--- | --- | ---
`id` | integer | primary identifier
`status` | string | one of: `pending`, `cancelled`, `complete`
`created_at` | string | timestamp
`updated_at` | string | timestamp
`client_data_type` | string | name of the client data class

### Requester

Who created the proposal. Refers to a [User](#user) record.

Attribute | Type | Note
--- | --- | ---
`id` | integer | primary identifier
`created_at` | string | timestamp
`updated_at` | string | timestamp

### Steps

Array of step objects.

Attribute | Type | Note
--- | --- | ---
`id` | integer | primary identifier
`status` | string | Can be `pending`, `actionable`, `approved`, or `canceled`
`user` | [User](#user) | who needs to complete the step

### Client data

The `client_data` object is the client-specific set of attributes. The attribute names
will vary based on the client. For example, [NCR](overview.md#national-capitol-region-ncr-service-centers) Work Order:

Attribute | Type | Note
--- | --- | ---
`amount` | string (decimal) | The cost of the work order
`building_number` | string | ([full list](../config/data/ncr.yaml))
`work_order_code` | `null` for BA61, string for BA80 | Identifier for the type of work
`description` | string |
`emergency` | boolean | Whether the work order was pre-approved or not (can only be `true` for BA61)
`expense_type` | string | `BA60`, `BA61` or `BA80`
`id` | integer |
`name` | string |
`not_to_exceed` | boolean | If the `amount` is exact, or an upper limit
`office` | string | The group within the service center who submitted the work order ([full list](../config/data/ncr.yaml))
`proposal` | [Proposal](#proposal) |
`rwa_number` | `null` for BA61, string for BA80 | Essentially the internal bank account number
`vendor` | string |

## Endpoints

### `GET /api/v2/proposals`

Fetch one or more proposals matching a query. Default is all proposals to which you are subscribed.

#### Query parameters

All are optional.

Name | Values
--- | ---
`size` | an integer >= 0
`from` | an integer >= 0
`limit` | alias for `size`
`offset` | alias for `from`
`status` | one of `pending`, `cancelled`, `complete`
`start_date` | timestamp string
`end_date` | timestamp.string
`text` | full-text search string. See https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax

##### Example

https://cap.18f.gov/api/v2/proposals?size=5&from=10&text=foo

### `GET /api/v2/proposals/:id`

Fetch a specific [Proposal](#proposal).

#### Query parameters

None

##### Example

https://cap.18f.gov/api/v2/proposals/12345

