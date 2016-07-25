var ObserverCardController;

ObserverCardController = (function(){
  
  function ObserverCardController(el, opts){
    $.extend(this, new ViewHelper());
    this.defaultSetup(el,opts);
    return this;
  }

  ObserverCardController.prototype._events = function(){
    this.initButton();
  }

  ObserverCardController.prototype._setConstants = function(el,opts){
    var self = this;
    this.el = typeof el === "string" ? $(el) : el;
    this.proposalId = $("#proposal_id").attr("data-proposal-id");
    this.updateEvent = "observer-card:update";
    this.updateCallback = this.setObserverForm;
    this.laddaButton = $(self.buttonSelector).ladda();
    this.submitUrl = "/proposals/" + self.proposalId + "/observations";
    this.buttonSelector = "#add_subscriber";
    this.contentSelector = ".observation-input";
  }

  ObserverCardController.prototype.setObserverForm = function(html, notificationData){
    this._selectize();
    this._hideUntilSelect();
    this.el.trigger('observer-card:updated', notificationData);
  }

  ObserverCardController.prototype._selectize = function(){
    this.el.find(".js-selectize").each(function(i, el){
       var selectizer = new Selectizer(el);
       selectizer.enable();
       selectizer.add_label();
    });
  }

  ObserverCardController.prototype._hideUntilSelect = function(){
    var self = this;
    this.el.find("[data-hide-until-select]").each(function (idx, el){
        self.hiddenUntilSelect = new HiddenUntilSelect(self.el, $(el));
    });
  }

  return ObserverCardController;

}());
window.ObserverCardController = ObserverCardController;
