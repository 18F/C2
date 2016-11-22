## Emails


C2's main interface for most users is email. As a result, there are many cases where you may need to edit emails. The following will provide some basic understanding of the email logic to date.


### Design


All of the C2 emails are designed to be responsive. To achieve this with ease, our emails have reusable parts that can be copied and pasted. The reusable parts are: `rows`, `columns`, and `subcolumns`. These parts are noted in the `views/mail_shared` and `views/*_mailer` view files. Note that in each mail view, there are a series of `table` elements and corresponding `tr` and `td` elements. 


The order of `table>tr>td` is very strict for emails. If there is any variance, then the layout will break the remainder of the template.


### Partials


To reduce changes on the email template design, partials are reused as much as possible, with `local` variable definitions.


Every email body block, must be wrapped in the `table.container` element. This block will restrict the width of the content and center it as needed. If the content in the layout is meant to be from end-to-end of the layout, then do not wrap the content in a `.container` element. This is necessary for full-width lines used as visual cues between content, such as a `hr`.


Each email has a `header`, `container`, and `footer`. For the header, use the `mail_shared/email_header/hero_text` partial. For the container, as mentioned above, wrap the content in a `table.container`. For the footer, each email layout will contain the `mail_shared/_footer.html.haml` partial.


See the `app/views/mail_shared` for partials and `app/views/*_shared/` content for more examples.


### Content


When building the emails, we had a designer, content producer, and developer. As a result, we had many cases where a design change was made across all the layouts. We also had cases where mass content changes were made across the emails. To make this easy to achieve, across the 20+ email templates, we actively separated the partials and content.


For the content, we use the `config/locales/mailers/en.yml` files. This allows us to make content updates in a central place. It is highly recommended to keep this process going, where email content changes are centralized in the locales file.


