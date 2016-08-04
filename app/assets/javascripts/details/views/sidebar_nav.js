var SidebarNav;

SidebarNav = (function(){
  function SidebarNav(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  SidebarNav.prototype._setup = function(){
    this._events();
  }

  SidebarNav.prototype._events = function(){
    var self = this;
    this.el.on('click', "a", function(event){
      var el = this;
      event.preventDefault();
      self.triggerSidebar(event, el);
    });
  }

  SidebarNav.prototype.triggerSidebar = function(event, el){
    console.log(event);
    console.log(el);
    this.lastEvent = event;
    this.lastEl = el;
  }

  return SidebarNav;

}());

window.SidebarNav = SidebarNav;
