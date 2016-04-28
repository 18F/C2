var ActionBar = function (el) {
  this.el = $(el);
  return this;
}

ActionBar.prototype._defaultMode = function () {
  this.el.removeClass('edit-actions');
  this.el.find('.save-button a').attr('disabled', true);
}

ActionBar.prototype._editMode = function () {
  this.el.addClass('edit-actions');
  this.el.find('.save-button a').attr('disabled', false);
}
