# API

This API is currently in a very limited alpha, and may not be enabled in 18F's production deployment. Note that this API may change or access may be restricted at any time, without warning.

## Data formats

* All decimals will be represented as strings – see https://github.com/rails-api/active_model_serializers/issues/202
* All times are in [ISO 8601](http://en.wikipedia.org/wiki/ISO_8601) format

## [NCR](overview.md#national-capitol-region-ncr-service-centers) Work Orders

### `GET /api/v1/ncr/work_orders.json`

#### Parameters

None.

#### Response

```javascript
[
  {
    // decimal value, returned as a string
    "amount": "1000.00",

    "building_number": "DC0017ZZ ,WHITE HOUSE-WEST WING1600 PA AVE. NW",

    // identifier for the type of work - `null` for BA61 requests, a string for BA80
    "code": "ABC",

    // whether the work order was pre-approved or not (can only be `true` for `expense_type: BA61`)
    "emergency": false,

    // can be 'BA61' or 'BA80'
    "expense_type": "BA80",

    "id": 16,

    // if the `amount` is exact, or an upper limit
    "not_to_exceed": false,

    // the group within the service center who submitted the work order
    "office": "P1121209 Security Management",

    // the central, generic data structure that maintains workflow information
    "proposal": {
      "approvals": [
        {
          "id": 92,

          // can be 'pending', 'approved', or 'rejected'
          "status": "pending",

          // the approver
          "user": {
            "created_at": "2015-01-10T07:05:42.445Z",
            "id": 43,
            "updated_at": "2015-01-10T07:05:42.445Z"
          }
        }
      ],

      "created_at": "2015-02-21T07:05:42.445Z",

      // can be 'linear' or 'parallel'
      "flow": "parallel",

      "id": 12,

      "requester": {
        "created_at": "2015-02-10T07:05:42.445Z",
        "id": 71,
        "updated_at": "2015-02-10T07:05:42.445Z"
      },

      // can be 'pending', 'approved', or 'rejected'
      "status": "pending",

      "updated_at": "2015-03-28T01:13:33.564Z"
    },

    // essentially the internal bank account number – `null` for BA61, a string for BA80
    "rwa_number": "123456A",

    "vendor": "ACME Corp"
  },
  // ...
]
```
