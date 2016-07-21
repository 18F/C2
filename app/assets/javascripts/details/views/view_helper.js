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
      this.updateCallback(html, opts);
    }
  }

  ViewHelper.prototype.defaultSetup = function(el,opts){
    $.extend(this,opts)
    this._setConstants(el,opts);
    this._events();
  }

  ViewHelper.prototype.initButton = function(){
    var self = this;
    this.el.on('click', self.buttonSelector, function(){
      self.laddaButton = $(self.buttonSelector).ladda();
      if( self.el.find(self.buttonSelector).attr('disabled') !== "disabled" ){
        self.laddaButton.ladda( 'start' );
        self.submitForm();
      } else {
        self.laddaButton.ladda( 'start' );
        window.setTimeout(function(){}, 300);
        self.laddaButton.ladda( 'stop' );
      }
    });
  }

  ViewHelper.prototype.submitForm = function(){
    var self = this;
    var params = {
      url: self.submitUrl,
      headers: {
        Accept : "text/javascript; charset=utf-8",
        "Content-Type": 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      data: self.el.find(self.contentSelector).serialize(),
      type: "post"
    }
    $.ajax(params);
  } 

  return ViewHelper;
}());
