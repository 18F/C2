# Use Case development

***This page is incomplete.***

Our codebase is (largely) split up into two sections: that which is core C2 code, and that which is specific to the use cases. See the descriptions of the current use cases in the [Overview](overview.md#use-cases). Differences from one use case to another include:

* Model
    * Fields
        * Validation
        * Defaults
    * Client
    * Version calculation
    * Approval flow
    * Automatically assigned approvers/observers
* Display of a single request (`show` page, emails, etc.)
    * Name
    * Public identifier
    * Displayed properties (`relevant_fields`)
* Dashboard (`/proposals`) – optional
    * Displayed properties
* Policy – optional
* Form
    * Ordering of fields
    * Possible/suggested options for various fields
    * Human-friendly names for fields
    * Hint text
* Eventually, possibly
    * `show` page template (e.g. display of a `Ncr::WorkOrder` being different from that of a `Gsa18fProcurement`)
    * Reporting
    * Custom dashboards (e.g. for budget reconcilers)
    * Overall styling
        * Logo
        * Colors
    * User affiliation (e.g. region)
    * User role (e.g. service center worker vs. budget analyst)
    * User relationships (e.g. supervisor)
    * Access control (e.g. service center directors can see _all_ requests in their region)
