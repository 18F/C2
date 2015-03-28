# API

***If you are running the server and want to enable the API, set the environment variable `API_ENABLED=true`.***

This API is currently in a very limited alpha, and may not be enabled in 18F's production deployment. Note that this API may change or access may be restricted at any time, without warning.

## Schemas

* All decimals are strings ([more info](https://github.com/rails-api/active_model_serializers/issues/202))
* All times are in [ISO 8601](http://en.wikipedia.org/wiki/ISO_8601) format

### Approval

Attribute | Type | Note
--- | --- | ---
`id` | integer |
`status` | string | Can be `pending`, `approved`, or `rejected`
`user` | [User](#user) | a.k.a. "the approver"

### [NCR](overview.md#national-capitol-region-ncr-service-centers) Work Order

Attribute | Type | Note
--- | --- | ---
`amount` | string (decimal) |
`building_number` | string |
`code` | `null` for BA61, string for BA80 | Identifier for the type of work
`emergency` | boolean | Whether the work order was pre-approved or not (can only be `true` for BA61)
`expense_type` | string | `BA61` or `BA80`
`id` | integer |
`name` | string | Shown as "description" in the form
`not_to_exceed` | boolean | If the `amount` is exact, or an upper limit
`office` | string | The group within the service center who submitted the work order
`proposal` | [Proposal](#proposal) |
`rwa_number` | `null` for BA61, string for BA80 | Essentially the internal bank account number
`vendor` | string |

### Proposal

The central, generic data structure that maintains workflow information.

Attribute | Type | Note
--- | --- | ---
`approvals` | [ [Approval](#approval) ] |
`created_at` | string (time) |
`flow` | string | Can be `linear` or `parallel`
`id` | integer |
`requester` | [User](#user) |
`status` | string | Can be `pending`, `approved`, or `rejected`
`updated_at` | string (time) |

### User

Attribute | Type | Note
--- | --- | ---
`created_at` | string (time) |
`id` | integer |
`updated_at` | string (time) |

## Endpoints

### `GET /api/v1/ncr/work_orders.json`

#### Parameters

None.

#### Response

Returns an array of [Work Orders](#ncr-work-order).

```javascript
[
  {
    "amount": "1000.00",
    "building_number": "DC0017ZZ ,WHITE HOUSE-WEST WING1600 PA AVE. NW",
    "code": "ABC",
    "emergency": false,
    "expense_type": "BA80",
    "id": 16,
    "name": "Blue paint for the Blue Room",
    "not_to_exceed": false,
    "office": "P1121209 Security Management",
    "proposal": {
      "approvals": [
        {
          "id": 92,
          "status": "pending",
          "user": {
            "created_at": "2015-01-10T07:05:42.445Z",
            "id": 43,
            "updated_at": "2015-01-10T07:05:42.445Z"
          }
        }
      ],
      "created_at": "2015-02-21T07:05:42.445Z",
      "flow": "parallel",
      "id": 12,
      "requester": {
        "created_at": "2015-02-10T07:05:42.445Z",
        "id": 71,
        "updated_at": "2015-02-10T07:05:42.445Z"
      },
      "status": "pending",
      "updated_at": "2015-03-28T01:13:33.564Z"
    },
    "rwa_number": "123456A",
    "vendor": "ACME Corp"
  },
  // ...
]
```
