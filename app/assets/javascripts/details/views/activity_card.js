var ActivityCardController;

ActivityCardController = (function(){

  function ActivityCardController(el, opts){
    $.extend(this, new ViewHelper());
    this.data = {
      url: "/proposals/7/comments",
      buttonSelector: "#add_a_comment",
      contentSelector: "#comment_text_content"
    }
    this.defaultSetup(el,opts);
    return this;
  }

  ActivityCardController.prototype._setConstants = function(el,opts){
    this.el = typeof el === "string" ? $(el) : el;
    this.proposalId = $("#proposal_id").attr("data-proposal-id");
    this.updateUrl = "/activity-feed/" + this.proposalId + "/update_feed";
    this.updateEvent = "activity-card:update";
    this.updateCallback = this.setCommentForm;
  }

  ActivityCardController.prototype._events = function(){
    var self = this;
    this._setupButton();
    this._setupUpdateEvent();
    this._setupCommentListToggle();
  }

  ActivityCardController.prototype._setupButton = function(){
    var self = this;
    var $button = $(self.data.buttonSelector);
    $button.on('click', function(){
      if( !$button.attr('disabled') !== true ){
        var params = {
          url: self.data.url,
          data: $(self.data.contentselector).serialize(),
          method: "POST"
        }
        $.ajax(params);
      }
    });
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
    opts = opts || {focus: false};
    if (opts.focus){
      this.el.find("textarea:first").focus();
    }
    this.el.find("#add_a_comment").attr('disabled', true);
    this.el.find("textarea:first").on('input',function(){
      $("#add_a_comment").attr('disabled', false);
    });
  }


  return ActivityCardController;

}());
window.ActivityCardController = ActivityCardController;
