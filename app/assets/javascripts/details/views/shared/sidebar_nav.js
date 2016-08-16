var SidebarNav;

SidebarNav = (function(){
  function SidebarNav(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  SidebarNav.prototype._setup = function(){
    this.navOptions = this.setSidebarOptions();
    this.checkUrl();
    this._events();
  }

  SidebarNav.prototype.setSidebarOptions = function(){
    var options = [];
    var triggers = this.el.find('[data-trigger]');
    triggers.each(function(i, item){
      var trigger = $(item).data('trigger');
      options.push(trigger)
    });
    return options;
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
    var self = this;
    if($.inArray(anchor, self.navOptions) === -1){
      anchor = "all";
    }
    this.el.find('.request-related-button [data-trigger="' + anchor + '"]').parent().addClass('active');
    this.updateUrl(anchor);
  }

  SidebarNav.prototype.defaultStart = function(){
    this.setActive($('.view-all-button'));
  }

  SidebarNav.prototype._events = function(){
    var self = this;
    this.el.on('click', "a", function(event){
      var el = this;
      if(self.shouldLink(el)){
        event.preventDefault();
        self.triggerSidebar(event, el);
      }
    });
    this.el.on("check-url", function(){
      self.checkUrl();
    });
    this.el.on("refresh-list", function(){
      self.refreshActive();
    });
    this.el.find('#header-toggle').on('click', function(){
      self.el.find('.link-container').on('on', function(){
        if( self.el.find('.link-container').hasClass('visible') ){
          self.el.find('.link-container').removeClass('visible');
        } else {
          self.el.find('.link-container').addClass('visible');
        }
      })
    })
  }

  SidebarNav.prototype.shouldLink = function(el){
    var linkCondition = ( $('body').hasClass('controller-proposals action-index') && $(el).data('trigger') !== undefined );
    if( linkCondition ){
      return true;
    } else {
      return false;
    }
  }

  SidebarNav.prototype.updateUrl = function(anchor){
    document.location.hash = anchor;
  }

  SidebarNav.prototype.setActive = function(el){
    this.el.find('li').removeClass('active');
    $(el).parent().addClass('active');
  }

  SidebarNav.prototype.getActive = function(){
    return this.el.find('.active [data-trigger]').attr('data-trigger');
  }

  SidebarNav.prototype.refreshActive = function(){
    var activeState = this.getActive();
    this.el.trigger('sidebar:button', activeState);
  }

  SidebarNav.prototype.triggerSidebar = function(event, el){
    var trigger = $(el).data('trigger');
    if(trigger !== undefined){
      var $parent = $(el).parent();
      this.updateUrl(trigger);
      if( $parent.hasClass('request-related-button') ){
        this.setActive(el);
      } else if ($parent.hasClass('requests-button')) {
        this.defaultStart();
      }
      this.el.trigger('sidebar:button', trigger);
    }
  }

  return SidebarNav;

}());

window.SidebarNav = SidebarNav;
