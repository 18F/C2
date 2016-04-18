# C2 API

***If you are running the server and want to enable the API, set the environment variable `API_ENABLED=true`.***

The API design is evolving. Backwards-incompatible changes will result in a version change.

The lastest version is **v2**.

Version **v1** has been removed completely.

Future versions will not necessarily deprecate previous versions. Backwards compatability will be
preserved wherever possible.

## Clients

See e.g. https://github.com/18F/c2-api-client-ruby for a ready-to-use API client. It handles
all the authentication for you.

## Authentication

Authentication is provided with OAuth2. You must:

* create an application with OAuth keys via https://cap.18f.gov/oauth/applications
* authorize your new application (click the **Authorize** button)
* use your OAuth keys to obtain an access token
* include your access token with every API request

Example:

```bash
% export MY_OAUTH_KEY=your-key-here
% export MY_OAUTH_SECRET=your-secret-here
% export MY_CREDS=`echo "$MY_OAUTH_KEY:$MY_OAUTH_SECRET" | base64`
% curl -i -X POST -H "Authorization: Basic $MY_CREDS" \
  -d 'grant_type=client_credentials' \
  https://cap.18f.gov/oauth/token
```

Take note of the `access_token` string value in the response. You will use it below as part of the
`Authorization: Bearer` header.

Consider using [a client library](https://github.com/18F/c2-api-client-ruby) instead,
so the authentication is handled for you.

## Schemas

* All decimals are strings ([more info](https://github.com/rails-api/active_model_serializers/issues/202))
* All times are in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format

### User

Attribute | Type | Note
--- | --- | ---
`id` | integer |
`created_at` | string (time) |
`updated_at` | string (time) |

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

Consult the [client data models](https://github.com/18F/C2/blob/master/app/models) themselves
for details on specific required attributes.

All attributes for `client_data` are present in responses, regardless of whether they have a value assigned.

## Endpoints

### `GET /api/v2/proposals`

Fetch one or more proposals matching a query. Default is all proposals to which you are subscribed.

The response includes 2 attributes: `total` and `proposals`. The total is an integer
which may be used in cooperation with the `size` and `from` query parameters in order to page
through results.

#### Query parameters

All are optional.

Name | Values
--- | ---
`size` | an integer >= 0 (defaults to 20)
`from` | an integer >= 0 (defaults to 0)
`status` | one of `pending`, `cancelled`, `complete`
`start_date` | timestamp string
`end_date` | timestamp.string
`text` | full-text search string. See https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax

#### Example

```bash
% curl -H 'Authorization: Bearer your-access-token' \
  https://cap.18f.gov/api/v2/proposals?size=5&from=10&text=foo
```

### `GET /api/v2/proposals/:id`

Fetch a specific [Proposal](#proposal).

#### Query parameters

None

#### Example

```bash
% curl -H 'Authorization: Bearer your-access-token' \
  https://cap.18f.gov/api/v2/proposals/12345
```

### `POST /api/v2/proposals`

Create a new [Proposal](#proposal). The root key is the client model slug, e.g. `ncr_work_order`.

#### Example

```bash
% curl -i -X POST -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer your-access-token' \
  --data @proposal.json \
  https://cap.18f.gov/api/v2/proposals
```

where `proposal.json` looks like:

```json
{
  "gsa18f_procurement": {
    "product_name_and_description": "some stuff",
    "cost_per_unit": 123.0,
    "quantity": 1,
    "justification": "because because because",
    "link_to_product": "18f.gov",
    "purchase_type": "Software"
  }
}
```

Consult the [client data models](https://github.com/18F/C2/blob/master/app/models) themselves
for details on specific required attributes.
