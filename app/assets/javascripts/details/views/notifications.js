var Notifications;

Notifications = (function(){
  function Notifications(el) {
    this.el = $(el);
    this._setup();
    return this;
  }
  
  Notifications.prototype._setup = function(){
    this._events();
  }

  Notifications.prototype._events = function(){
    this._closeButton()
  }

  Notifications.prototype.create = function(params){
    var notice = this._prepare(params);
    this._postNotification(notice);
  }

  Notifications.prototype._closeButton = function(el){
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

  Notifications.prototype._postNotification = function(notice){
    var self = this;
    this.el.find('ul').append(function() {
      return $(notice);
    })
  }

  Notifications.prototype._prepare = function(params){
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

  Notifications.prototype.clearAll = function(){
    var $notices = this.el.find('.notification-bar-el');
    $notices.animate({
      "min-height": "0px", 
      height: "0px"
    }, 500, 
    function(){ 
      $notices.remove();
    });
  }

  return Notifications;

}());

window.Notifications = Notifications;
