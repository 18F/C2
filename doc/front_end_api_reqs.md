Front End API Requirements
==========================

As part of the (currently upcoming) front end redesign, we want users to browse
and edit Proposals with fewer page reloads. We'll be decorating several key
views with Javascript that, where possible, makes REST API calls to perform
updates and fetch new data.

These are initial notes for where we see those APIs needed, and what they should
do.

# Proposals

## Proposal JSON object

### Base fields

 - **`id`:** _Should this be sent as a string or an int?_
 - **`public_id`:** string
 - **`url`:** string, canonical URL for viewing/editing this proposal
 - **`title`:** string, pulled from `ncr_work_orders.project_title` or `gsa18f_procurements.product_name_and_description`
 - **`total_price`:** decimal string (since floats are terrible for handling money amounts),  pulled from `ncr_work_orders.amount` or `gsa18f_procurements.total_price`
 - **`status`:** string, one of `pending`, `completed`, `canceled`
 - **`status_description`:** string, used in the "Status" column of the list view to display such strings as `Completed` or `Waiting for approval from...` (See open questions)
 - **`client`:** string, currently one of `ncr`, `gsa18f`
 - **`created`:** date string
 - **`updated`:** date string _(see open question below)_
 - **`latest_activity`:** sub-object, containing:
   - **`type`:** string, one of `comment`, `attachment`, `modification`, `approval`, `cancelation`
   - **`date`:** date string
   - **`user`:** User sub-object (see below)

### Base relations

 - **`requester`:** User sub-object

Relations are serialized as sub-objects (or arrays of sub-objects) which include key fields from the linked object. As a general rule, fields included should be:

 - `id`
 - `relation_url`: the full URL for manipulating the relation, but only included
 if the route exists. (I think we'd only use this for a `DELETE`)
 - anything needed for display (so in the User case, `name` and `email_address`)

### NCR fields

_Should client-specific fields be at the top level in the object alongside the base fields, or in a sub-object?_

  - **`ncr_work_order_id`**
  - **`project_title`:** string _(Is this worth including as well as `title` above?)_
  - **`expense_type`:** string
  - **`building_number`:** string
  - **`rwa_number`:** string
  - **`code`:** string
  - **`function_code`:** string
  - **`soc_code`:** string
  - **`not_to_exceed`:** boolean
  - **`direct_pay`:** boolean
  - **`emergency`:** boolean

### NCR relations

Several of these are currently implemented as singleton fields in the NCR Work
Order, but our user testing showed that users often want to include multiples,
so we'll need to create these models and relations on the backend as well.

  - **`approving_official`:** User sub-object
  - **`ncr_organization`:** NCR Organization sub-object
  - **`cl_number`:** Array of CL Number sub-objects
  - **`vendor`:** Array of Vendor sub-objects

### GSA18F fields

  - **`office`:** string
  - **`justification`:** string
  - **`additional_info`:** string
  - **`link_to_product`:** string
  - **`quantity`:** integer
  - **`cost_per_unit`:** decimal string
  - **`urgency`:** integer
  - **`purchase_type`:** integer
  - **`recurring`:** boolean
  - **`recurring_interval`:** string
  - **`recurring_length`:** integer
  - **`date_requested`:** date string

_Given the way we'll use `urgency` and `purchase_type` in forms, it's probably
best we keep them as ints._

### Open questions

  - Is the `status description` field a better solution than always supplying a `steps` array and computing the status description on the client side?
  - Should client-specific fields be at the top level in the object alongside the base fields, or in a sub-object?
  - Is it worth deriving `updated` from `Proposal.updated_at`, given that it won't
  reflect updates made to client data, comments etc? Is it better to copy it from
  `latest_activity` or just exclude it?

## List view: `GET /api/proposals/`

In the new design for list views of Proposals, the user should be able to
search, sort and filter the set of viewable proposals, then page through the
results returned. Not all of these features _need_ to be implemented
at the API level (but they probably should be).

At the moment, for the needs of the front end, I'm assuming that:

 - the API is being called on behalf of a specific logged-in user
 - who has a client slug for **one** client
 - ...

The returned JSON document should have two top-level keys:

 - **`metadata`:** Data about the query and result set, such as:
   - **`total`:** Total number of results _available_ (but not necessarily included in this document)
   - **`count`:** Number of results included in the `results` section of this document
   - **`offset` & `limit`:** The paging arguments used to limit the results. Will mirror the values supplied in the `offset` & `limit` params if they were supplied and legal, otherwise the defaults.
   - _(Include `prev` and `next` URLs for paging?)_
 - **`results`:** A JSON Array containing Proposal objects.

### Primary features

#### Limit results by authorization

The API should only ever return results that the logged-in user is authorized to
see. This also includes limiting to the user's client slug.

#### Searching/Filtering

Handle the same `QUERY_STRING` parameters as `ProposalListingQuery`.

### Secondary features

Some or all of these can have their first implementation on the JS side if necessary, but ideally they should be handled at the API level.

#### Paging

Use of `offset` & `limit` params to select a range of results to return.

_Open question: Should there be a default `limit`? At present we don't have enough records that an unlimited query of Proposal objects would return a problematically-large result set, but this might not be the case in the future._

#### Sorting

The `sort` param can specify a field on which to sort the results. If the `desc` param exists, the results are sorted in descending order; the default is ascending order.

If paging is implemented on the API side, sorting **must** be implemented there too.

#### Field limiting

_Not sure how necessary this one is - am currently guessing it's not, given that Proposal objects won't be large, but it may turn out otherwise._

If the `fields` param is present and is a legal comma-separated list of field names, then the Proposal objects included in the `results` array should **only** include these fields:

  - `id`
  - `url`
  - the fields in the supplied list

## Update individual proposal: `PUT/PATCH /api/proposals/:id`

TBC

 - _Should updates to client data be made through this endpoint or one dedicated
 to the client data type?_

## Observations

_Do we need a `GET` route for either the List, or individual observations? I'm not including them yet because I assume they'll be rendered in the initial view._

### Add Observation: `POST /api/proposals/:proposal_id/observations`

POST a JSON object containing a `user_id` with an integer value. Returns 201 on success and a JSON object with
 - `id` (of the observation)
 - `url` (for DELETE)

### Delete Observation: `DELETE /api/proposals/:proposal_id/observations/:observation_id`

Returns 200 on success.

## Steps

_Not seeing a need for API access yet._

## Attachments

_Again, don't yet see a need for a `GET` route here._

### Add Attachment: `POST /api/proposals/:proposal_id/attachments`

TBC

### Delete Attachment: `DELETE /api/proposals/:proposal_id/attachments/:attachment_id`

TBC
