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
    this._closeButton()
  }

  NotificationBars.prototype.create = function(params){
    console.log('Notification created');
    var notice = this._prepare(params);
    this._postNotification(notice);
  }

  NotificationBars.prototype._closeButton = function(el){
    this.el.delegate('.close', 'click', function(){
      var el = this;
      var $notice = $(el).closest('.notification-bar-el');
      $notice.animate({
        "min-height": "0px", 
        height: "0px"
      }, 500, 
      function(){ 
        $notice.remove();
      });
    })
  }

  NotificationBars.prototype._postNotification = function(notice){
    var self = this;
    this.el.find('ul').append(function() {
      return $(notice);
    })
  }

  NotificationBars.prototype._prepare = function(params){
    var type    = (params['type']) ? params['type'] : 'primary';
    var title   = (params['title']) ? params['title'] : '';
    var content = (params['content']) ? params['content'] : '';
    var timeout = (params['timeout']) ? params['timeout'] : false;
    
    var notice =  '<li class="notice-type-' + type + ' notification-bar-el" data-timeout="' + timeout + '">' +
                    '<div class="row">' +
                      '<span class="notification-title">' + title + '</span><span class="notification-content">' + content + '</span>' +
                      '<button class="close">Close</button>' +
                    '</div>' +
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
