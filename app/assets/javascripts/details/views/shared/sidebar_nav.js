var SidebarNav;

SidebarNav = (function(){
  function SidebarNav(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  SidebarNav.prototype._setup = function(){
    this.checkUrl();
    this._events();
  }

  SidebarNav.prototype.checkUrl = function(){
    var anchorValue;
    var strippedUrl = document.location.toString().split("#");
    if (strippedUrl.length > 1){
      anchorValue = strippedUrl[1];
      this.checkAnchorValue(anchorValue);
    } else if(location.pathname === "/proposals") {
      this.defaultStart();
    }
  }

  SidebarNav.prototype.checkAnchorValue = function(anchor){
    this.el.find('[data-trigger="' + anchor + '"]').parent().addClass('active');
  }

  SidebarNav.prototype.defaultStart = function(){
    $('.view-all-button').parent().addClass('active');
  }

  SidebarNav.prototype._events = function(){
    var self = this;
    this.el.on('click', "a", function(event){
      var el = this;
      if(self.shouldLink){
        event.preventDefault();
      }
      self.triggerSidebar(event, el);
    });
  }

  SidebarNav.prototype.shouldLink = function(){
    if( $('body').hasClass('controller-proposals action-index') ){
      return true;
    } else {
      return false;
    }
  }

  SidebarNav.prototype.setActive = function(el){
    this.el.find('li').removeClass('active');
    $(el).parent().addClass('active');
  }

  SidebarNav.prototype.triggerSidebar = function(event, el){
    var trigger = $(el).data('trigger');
    document.location.hash = trigger;
    this.setActive(el);
    this.el.trigger('sidebar:button', trigger);
  }

  return SidebarNav;

}());

window.SidebarNav = SidebarNav;
