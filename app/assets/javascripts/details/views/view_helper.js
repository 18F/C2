var ViewHelper;

ViewHelper = (function(){
  function ViewHelper(){
    return this;
  }

  ViewHelper.prototype._setupUpdateEvent = function(){
    var self = this;
    this.el.on(self.updateEvent, function(){
      $.ajax({ url: self.updateUrl, 
        retryLimit: 5,
        success: function(html){
          self.update(html);
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

  ViewHelper.prototype.update = function(html,opts){
    opts = opts || {focus: false};
    this.el.html(html);
    if(this.updateCallback){
      this.updateCallback();
    }
  }

  ViewHelper.prototype.defaultSetup = function(el,opts){
    $.extend(this,opts)
    this._setConstants(el,opts);
    this._events();
  } 

  return ViewHelper;
}());
