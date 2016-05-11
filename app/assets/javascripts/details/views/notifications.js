var NotificationBars;

NotificationBars = (function(){
  function NotificationBars(el) {
    this.el = $(el);
    this._setup();
    return this;
  }
  
  NotificationBars.prototype._setup = function(){
    this._events();
  }

  NotificationBars.prototype._events = function(){

  }

  return NotificationBars;

}());

window.NotificationBars = NotificationBars;
