## ElasticSearch

The C2 project has a few areas dependent on ElasticSearch.

Specifically:

- Search
- Reporting

This section will go over some of the expected behavior associated to these areas.

### Search

The C2 advanced search is based on making ElasticSearch queries and filtering the results based on the current user parameter. When using the advanced search on a `proposals#index` page, there are two processes that querie the backend search endpoints.

First, the text fields for the advanced search use a javascript keypress monitor to get "live" query results. These results are used to populate the "number of results" counter at the bottom of the advanced search field. The file processing advanced search functionality is found ing `app/assets/javascripts/search.js`.

Second, once the advanced search form is submitted, the query is processed to display the corresponding results. The query is processed by the files in the `app/queries/*` files, starting with the `proposal_query.rb` file. While these files are called, any direct searches should explicitly be conducted using the `Proposal.search()` method.

For example, to search a broad term such as "hardware", use `Proposal.search("hardware")`. Similarly, key/value pairs can be passed to search specific ElasticSearch indexed keys.

Once the query is processed, the results are returned and displayed using the `proposal_listing_query.rb` file.

### Indexing

ElasticSearch indexing allows for flattening the data structures being searched. After indexing, there is no need to run various methods attributed to a `Proposal`, to gather the subscribers or attachments. The `Proposal` and correspondingly indexed values will be directly accessible in a flat data structure.

Proposals are indexed based on the ElasticSearch DSL method. At the time of developing this feature, the ElasticSearch DSL method was identified as best practice.

The indexed fields can be found and configured using the Proposals model, found at: `app/models/proposal.rb`. Using the `settings index:` action, a hash with specific fields can be set. If there are any methods/actions that need to be run on indexing, they should be added accordingly to the `as_indexed_json` method.

### Determining which items are surfaced

Proposals are surfaced to users based on the user's `client_slug`. Based on the `client_slug`, various `client_data_type` models can be surfaced.

For example, the `gsa18f` users have the `Procurement` and `Event` models available to them through search.

### Questions

`app/queries/*` is the best starting place for any questions about how the search queries are processed.
