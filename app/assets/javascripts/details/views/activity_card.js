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
    this.laddaButton = $(self.data.buttonSelector).ladda();
    this.proposalId = $("#proposal_id").attr("data-proposal-id");
    this.updateUrl = "/activity-feed/" + this.proposalId + "/update_feed";
    this.updateEvent = "activity-card:update";
    this.updateCallback = this.setCommentForm;
    this.data = {
      url: "/proposals/" + self.proposalId + "/comments",
      buttonSelector: "#add_a_comment",
      contentSelector: "#comment_text_content"
    }
  }

  ActivityCardController.prototype._events = function(){
    var self = this;
    this.initButton();
    this._setupUpdateEvent();
    this._setupCommentListToggle();
  }

  ActivityCardController.prototype.initButton = function(){
    var self = this;
    this.el.on('click', self.data.buttonSelector, function(){
      self.laddaButton = $(self.data.buttonSelector).ladda();
      if( self.el.find(self.data.buttonSelector).attr('disabled') !== "disabled" ){
        self.laddaButton.ladda( 'start' );
        self.submitComment();
      } else {
        self.laddaButton.ladda( 'start' );
        window.setTimeout(function(){}, 300);
        self.laddaButton.ladda( 'stop' );
      }
    });
  }

  ActivityCardController.prototype.submitComment = function(){
    var self = this;
    var params = {
      url: self.data.url,
      headers: {
        Accept : "text/javascript; charset=utf-8",
        "Content-Type": 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      data: self.el.find(self.data.contentSelector).serialize(),
      type: "POST"
    }
    $.ajax(params);
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
      this.el.find(self.data.contentselector).focus();
    }
    this.el.find(self.data.buttonSelector).attr('disabled', true);
    this.el.find(self.data.contentselector).on('input',function(){
      this.el.find(self.data.buttonSelector).attr('disabled', false);
    });
    self.laddaButton.ladda( 'stop' );
  }


  return ActivityCardController;

}());
window.ActivityCardController = ActivityCardController;
