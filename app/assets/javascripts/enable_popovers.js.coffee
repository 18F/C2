# Enables Bootstrap's JS popovers:
# http://getbootstrap.com/javascript/#popovers
# To format the data attributes for popover usage, see
# UiHelper::popover_data_attrs()

$ ->
  $('[data-toggle="popover"]').popover()
