Each stylesheet in this directory should correspond to the path of a view, and should have a single top-level class that follows the pattern `.m-DIR-FILE`. For example, `stylesheets/modules/carts/cart_items.scss` should correspond to `views/carts/_cart_items.html.erb`, and contain the following:

```scss
.m-carts-cart_items {
  // ...
}
```
