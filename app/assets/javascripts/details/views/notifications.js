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

  NotificationBars.prototype.create = function(params){
    var notice = this._prepare(params);
    this.postNotification(notice);
  }

  NotificationBars.prototype.postNotification = function(notice){
    this.el.find('ul').append(notice);
  }

  NotificationBars.prototype._prepare = function(params){
    var type    = (params['type']) ? params['type'] : 'primary';
    var title   = (params['title']) ? params['title'] : '';
    var content = (params['content']) ? params['content'] : '';
    var timeout = (params['timeout']) ? params['timeout'] : false;
    
    var notice = '<li class="notice-type-' + type + ' notification-bar-el" data-timeout="' + timeout + '">' +
      '<div><h4>' + title + '</h4><p>' + content + '</p></div>' + 
    '</li>';
    
    return notice
  }

  NotificationBars.prototype.clearAll = function(){
  }

  // Use the ID to select which to clear
  NotificationBars.prototype.clearOne = function(id){
    
  }

  return NotificationBars;

}());

window.NotificationBars = NotificationBars;
