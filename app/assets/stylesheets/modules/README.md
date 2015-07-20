Each stylesheet in this directory should correspond to the path of a view, and should have a single top-level class that follows the pattern `.m-DIR-FILE`. For example, `stylesheets/modules/proposals/proposal_items.scss` should correspond to `views/proposals/_proposal_items.html.erb`, and contain the following:

```scss
.m-proposals-proposal_items {
  // ...
}
```
