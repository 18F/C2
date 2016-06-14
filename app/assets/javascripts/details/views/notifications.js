var Notifications;

Notifications = (function(){
  function Notifications(el) {
    this.data = {
      noticeId: 0
    }
    this.el = $(el);
    this._setup();
    return this;
  }
  
  Notifications.prototype._setup = function(){
    var flashMessages = $('meta[name="flash-message"]');
    this._events();
    this._prepareOnLoadNotifications(flashMessages);
  }

  Notifications.prototype._prepareOnLoadNotifications = function(flashMessages){
    var notices = [];
    var flashes = flashMessages;
    for (var i = flashes.length - 1; i >= 0; i--) {
      var flash = $(flashes[i]);
      var param = {
        title: "",
        content: flash.attr("content"),
        type: flash.attr("type")
      }
      this.create(param);
    }
  }

  Notifications.prototype._events = function(){
    this._closeButton()
  }

  Notifications.prototype.create = function(params){
    var notice = this._prepare(params);
    this._postNotification(notice);
  }

  Notifications.prototype._closeButton = function(el, animateLength){
    var time = animateLength || 500
    this.el.delegate('.close', 'click', function(){
      var el = this;
      var $notice = $(el).closest('.notification-bar-el');
      $notice.animate({
        "min-height": "0px", 
        height: "0px"
      }, time, 
      function(){ 
        $notice.remove();
      });
    })
  }

  Notifications.prototype._postNotification = function(notice){
    var self = this;
    var id = this.data.noticeId;
    var noticeBar = $(notice);

    this.data.noticeId = this.data.noticeId + 1;
    this.el.find('ul').append(noticeBar);
    this.initClose(id)
  }

  Notifications.prototype.initClose = function(id){
    var self = this;
    var el = $("#notification-id-" + id);
    if (el.length > 0){
      var timeout = el.attr('data-timeout');
      if (timeout !== "none"){
        var progress = new ProgressBar.Circle("#notification-id-" + id + " .close", { 
          strokeWidth: 3,
          duration: timeout,
          color: '#40759C',
          trailColor: '#DAEAf5',
          trailWidth: 3,
          svgStyle: null
        });
        progress.animate(1);
        var timer = window.setTimeout(function(){
          if(el.attr('data-clicked') !== true){
            self.clearOne(el);
          }
        }, timeout);
      }
    }
    // this.notificationEvent(id, timer);
  }

  Notifications.prototype.notificationEvent = function(id, timer){
    var self = this;
    var el = $("#notification-id-" + id);
    el.on('click', function(e){
      if( $(this).attr('data-clicked') === true ){
        self.initClose(id);
        $(this).attr('data-clicked', 'false');
      } else {
        clearTimeout(timer);
        el.find('svg').remove();
        $(this).attr('data-clicked', 'true');
      }
    });
  }

  Notifications.prototype._prepare = function(params){
    if ( params['type'] === "alert" ){
      params['timeout'] = "none";
    }
    var id      = this.data.noticeId;
    var type    = (params['type']) ? params['type'] : 'primary';
    var title   = (params['title']) ? params['title'] : '';
    var content = (params['content']) ? params['content'] : '';
    var timeout = (params['timeout']) ? params['timeout'] : 5000;

    var notice =  '<li id="notification-id-' + id + '" class="notice-type-' + type + ' notification-bar-el" data-timeout="' + timeout + '">' +
                    '<div class="row">' +
                      '<span class="notification-title">' + title + '</span><span class="notification-content">' + content + '</span>' +
                      '<button class="close">&#215;</button>' +
                    '</div>' +
                  '</li>';
    
    return notice
  }

  Notifications.prototype.clearOne = function(el){
    el.find('*').animate({
      opacity: 0
    }, 100);
    el.animate({
      "min-height": "0px", 
      height: "0px"
    }, 250, 
    function(){ 
      el.remove();
    });
  }

  Notifications.prototype.clearAll = function(){
    var self = this;
    var $notices = this.el.find('.notification-bar-el');
    $notices.each(function(i, item){
      self.clearOne($(item));
    });
  }

  return Notifications;

}());

window.Notifications = Notifications;
