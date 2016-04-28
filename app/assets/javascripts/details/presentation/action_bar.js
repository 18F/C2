var ActionBar = function (el) {
  this.el = $(el);
  return this;
}

ActionBar.prototype.defaultMode = function () {
  this.el.removeClass('edit-actions');
  this.el.find('.save-button a').attr('disabled', true);
}

ActionBar.prototype.editMode = function () {
  this.el.addClass('edit-actions');
  this.el.find('.save-button a').attr('disabled', false);
}
