var ObserverCardController;

ObserverCardController = (function(){
  
  function ObserverCardController(el, opts){
    this._setup(el,opts);
    return this;
  }

  ObserverCardController.prototype._setup = function(el,opts){
    $.extend(this,opts)
    this.el = typeof el === "string" ? $(el) : el;
  }

  ObserverCardController.prototype.update = function(html){
    this.el.html(html);
    this._selectize();
    this._hideUntilSelect();
    this.el.trigger('observer-card:updated');
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
