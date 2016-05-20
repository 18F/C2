var ActivityCardController;

ActivityCardController = (function(){
  
  function ActivityCardController(el, opts){
    this._setup(el, opts);
    return this;
  }

  ActivityCardController.prototype._setup = function(el,opts){
    $.extend(this,opts)
    this.el = typeof el === "string" ? $(el) : el;
    this._events();
  }

  ActivityCardController.prototype._events = function(){
    var self = this;
    this._setupUpdateEvent();
    this._setupCommentListToggle();
  }

  ActivityCardController.prototype._setupCommentListToggle = function(){
    var self = this;

    this.el.on('click','.status-contract-action, .status-expand-action', function(){
      self.el.find('.toggle-contracted')
        .toggleClass('status-contracted')
        .toggleClass('status-expanded');
      self.el.find('.status-contract-action').toggle();
      self.el.find('.status-expand-action').toggle();

      return false;
    });
  }

  ActivityCardController.prototype._setupUpdateEvent = function(){
    this.el.on("activity-card:update", function(){
      var proposal_id = $("#proposal_id").attr("data-proposal-id");
      $.ajax({ url: "/activity-feed/" + proposal_id + "/update_feed", 
        retry_limi: 5,
        success: function(html){
          self.update(html, {focus: false});
        }, 
         error : function(xhr, textStatus, errorThrown ) {
          if (textStatus === "timeout") {
            this.tryCount++;
            if (this.tryCount <= this.retryLimit) {
              //try again
              $.ajax(this);
              return;
            }            
            return;
          }
        } 
      });
    });
  }

  ActivityCardController.prototype.update = function(html, opts){
    opts = opts || {focus: true};
    this.el.html(html);
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
