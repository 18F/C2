## Setting up a new C2 client

This document describes the details of setting up a new C2 client.

### Overview

A *client* represents a group of Users within the C2 system that share
a data model. Existing examples include **GSA18F** and **NCR**.

Within a *client* users may be assigned different roles. See the [Authorization](roles.md)
document for details on roles.

A *client* namespace is assigned to each User via a `client_slug` model value. The
convention is that the `client_slug` is a downcased string matching the client model
namespace. For example `ncr` for **NCR**.

A User without an assigned `client_slug` may not create, edit, view or search Proposals,
since the User will have no authorization context. The User may, however, login to the system.

### Models

The first thing to identify when adding a new client is the data schema for the client-specific
extension to the Proposal. This extension is called *client_data*.

Here is an example db migration for a new client called **Foo** with a client_data schema
called **SpendingRequest**:

```ruby
class AddFooSpendingRequests < ActiveRecord::Migration
  def change
    create_table :foo_spending_requests do |t|
      t.decimal  :amount
      t.string   :project_title
      t.timestamps null: false
    end
  end
end
```

Here is an example of the corresponding ActiveRecord model class:

```ruby
module Foo
  def self.table_name_prefix
    "foo_"
  end

  class SpendingRequest < ActiveRecord::Base
    def self.purchase_amount_column_name
      :amount
    end

    include ClientDataMixin
    include PurchaseCardMixin

    def editable?
      true
    end

    def name
      project_title
    end

  end
end
```

Here is how you would use the new model:

```ruby
requester = User.for_email('some.user@example.com')
spending_request = Foo::SpendingRequest.new(
  amount: 123.00, 
  project_title: 'my request'
)
proposal = ClientDataCreator.new(spending_request, requester).run
```

Here is an example Factory for writing tests:

```ruby
FactoryGirl.define do
  factory :foo_spending_request, class: Foo::SpendingRequest do
    amount 123
    project_title "I am a test request"
    association :proposal, client_slug: "foo"

    trait :with_approvers do
      association :proposal, :with_serial_approvers, client_slug: "foo"
    end
  end
end
```

### Controllers

Here is an example controller for the `Foo::SpendingRequest` class, which
you could drop into `app/controllers/foo/spending_requests_controller.rb`.

```ruby
module Foo
  class SpendingRequestsController < ClientDataController
    MAX_UPLOADS_ON_NEW = 10

    protected

    def spending_request
      @client_data_instance
    end

    def record_changes
      ProposalUpdateRecorder.new(spending_request).run
    end

    def model_class
      Foo::SpendingRequest
    end

    def permitted_params
      fields = spending_request_params
      params.require(:foo_spending_request).permit(*fields)
    end

    def spending_request_params
      Foo::SpendingRequest.relevant_fields()
    end
  end
end
```

### Views

Here are example view files for the `Foo::SpendingRequest` model.

In `app/views/foo/spending_requests/new.html.haml`:

```
= render "form"
```

In `app/views/foo/spending_requests/edit.html.haml`:

```
= render "form"
```

In `app/views/foo/spending_requests/_attachments.html.haml`:

```
.form-group
  = field_set_tag 'Attachments' do
    %ul.attachments{ data: { add_minus: true } }
      - Foo::SpendingRequestsController::MAX_UPLOADS_ON_NEW.times do
        %li
          = file_field_tag "attachments[]"
```

In `app/views/foo/spending_requests/_form.html.haml`;

```
- content_for :title, "Foo Spending Request"
.container.content.m-request-form
  %h2
    Foo
  %h3
    Spending Request

  %p
    %em
      * Indicates a required field

  = simple_form_for @client_data_instance, html: { multipart: true } do |f|
    = f.input :project_title
    = field_set_tag "Amount", class: "required" do
      = f.input :amount,
        as: :currency,
        label_html: { class: "sr-only" },
        input_html: { data: popover_data_attrs("ncr_amount") }
      = f.input :not_to_exceed,
        as: :radio_buttons,
        collection: [["Exact", false], ["Not to exceed", true]], label: false
    - if @client_data_instance.new_record?
      = render partial: 'attachments'
    = f.submit class: "form-button"
    - if @client_data_instance.persisted?
      = link_to "Discard Changes", proposal_path(@client_data_instance.proposal), class: "discard-link"
```

### Routes

Here is an example edit to `config/routes.rb`:

```ruby
  namespace :foo do
    resources :spending_requests, except: [:index, :destroy]
  end
```

