var ApprovalCardController;

ApprovalCardController = (function(){
  
  function ApprovalCardController(el, opts){
    $.extend(this, new ViewHelper());
    this.defaultSetup(el,opts);
    return this;
  }

  ApprovalCardController.prototype._setConstants = function(el,opts){
    this.el = typeof el === "string" ? $(el) : el;
    this.proposalId = $("#proposal_id").attr("data-proposal-id");
    this.updateUrl = "/approval-feed/" + this.proposalId + "/update_approvals";
    this.updateEvent = "status-card:update";
  }

  ApprovalCardController.prototype._events = function(){
    this._setupUpdateEvent();
  }

  return ApprovalCardController;

}());
window.ApprovalCardController = ApprovalCardController;
