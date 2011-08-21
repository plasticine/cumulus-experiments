API
===


Create an account
-----------------

### Requst

    POST /accounts


Get an account
--------------

### Requst

    GET /accounts/:account_id

Required headers:

* `X-API-Token`: The API token for the user's account.

### Example

    GET /accounts/acme


Create a fact
-------------

### Request

    POST /facts

Body:

    {
      timestamp: 123,
      fact_type: page_view,
      properties: {
        request_time: 100
      }
    }

Required headers:

* `X-API-Token`: The API token for the user's account.

### Response

Normal response codes:

* `201 Created`


Get a metric
---------------------------

    GET /metrics/:fact_type

Required headers:

* `X-API-Token`: The API token for the user's account.

### Example

    GET /metrics/page_views?frequency=minute

### Response

Normal reponse codes:

* `200 OK`

Body:

    {
      metadata: {
        properties: [
          {name: "request_time"},
          {name: "page_views"}
        ]
      },
      data: [
        {timestamp: 1200, request_time: 123, page_views: 100},
        {timestamp: 1260, request_time: 456, page_views: 200}
      ]
    }
