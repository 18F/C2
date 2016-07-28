var ActivityCardController;

ActivityCardController = (function(){

  function ActivityCardController(el, opts){
    $.extend(this, new ViewHelper());
    this.defaultSetup(el,opts);
    return this;
  }

  ActivityCardController.prototype._setConstants = function(el,opts){
    var self = this;
    this.el = typeof el === "string" ? $(el) : el;
    this.proposalId = $("#proposal_id").attr("data-proposal-id");
    this.updateUrl = "/activity-feed/" + this.proposalId + "/update_feed";
    this.updateEvent = "activity-card:update";
    this.updateCallback = this.setCommentForm;
    this.laddaButton = $(self.buttonSelector).ladda();
    this.submitUrl = "/proposals/" + self.proposalId + "/comments";
    this.buttonSelector = "#add_a_comment";
    this.contentSelector = "#comment_text_content";
  }

  ActivityCardController.prototype._events = function(){
    var self = this;
    this.initButton();
    this._setupUpdateEvent();
    this._setupCommentListToggle();
    this.el.on('focus input propertychange', '[name="comment[comment_text]"]', function(){
      if ($('[name="comment[comment_text]"]').val() === ""){
        $(self.buttonSelector).attr('disabled', true);
      } else {
        $(self.buttonSelector).attr('disabled', false);
      }
    });
  }

  ActivityCardController.prototype.onButtonPress = function(){
    $('[name="comment[comment_text]"]').attr('disabled', true);
  }

  ActivityCardController.prototype._setupCommentListToggle = function(){
    var self = this;

    this.el.on('click','.status-contract-action, .status-expand-action', function(){
      var classes = ".status-contracted, .status-contract-action, .status-expand-action";
      self.el.find(classes).toggle();
      return false;
    });
  }

  ActivityCardController.prototype.setCommentForm = function(opts){
    var self = this;
    opts = opts || {focus: false};
    if (opts.focus){
      this.el.find(self.contentselector).focus();
    }

    $('[name="comment[comment_text]"]').attr('disabled', false);
    this.setupReloadButtonState();
  }

  ActivityCardController.prototype.setupReloadButtonState = function(){
    var self = this;
    self.laddaButton.ladda( 'stop' );
    self.laddaButton = self.laddaButton.ladda();
    self.laddaButton.attr('disabled', true);
    $(self.contentselector).focus();
  }

  return ActivityCardController;

}());
window.ActivityCardController = ActivityCardController;
