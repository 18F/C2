# API

This API is currently in a very limited alpha, and may not be enabled in 18F's production deployment.

## [NCR](../README.md#national-capitol-region-ncr-service-centers) Work Orders

### `GET /api/v1/ncr/work_orders.json`

#### Parameters

None.

#### Response

```javascript
[
  {
    "amount": "1000.0",
    "building_number": "DC0017ZZ ,WHITE HOUSE-WEST WING1600 PA AVE. NW",
    "code": null,
    "emergency": false,
    "expense_type": "BA61",
    "id": 16,
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
