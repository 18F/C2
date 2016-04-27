var NotificationBar = function (el) {
  this.el = $(el);
  return this;
}

NotificationBar.prototype.display = function () {
  this.el.find('.action-status-value').text(message);
  this.el.fadeIn();
  window.setTimeout(function(){
    this.el.fadeOut();
  }, 3000);
}
