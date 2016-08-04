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
    this.el.on('dataTableView:canceled', function(){
      self.viewCanceled();
    });
    this.el.on('dataTableView:pending', function(){
      self.viewPending();
    });
    this.el.on('dataTableView:completed', function(){
      self.viewCompleted();
    });
    this.el.on('dataTableView:all', function(){
      self.viewAll();
    });
  }

  SidebarNav.prototype.viewPending = function(){
    this.dataTable.column(':contains(Status)').search('Waiting for review from').draw();
  }

  SidebarNav.prototype.viewCanceled = function(){
    this.dataTable.column(':contains(Status)').search('Canceled').draw();
  }

  SidebarNav.prototype.viewAll = function(){
    this.dataTable.column(':contains(Status)').search('').draw();
  }

  SidebarNav.prototype.viewCompleted = function(){
    this.dataTable.column(':contains(Status)').search('Completed').draw();
  }

  return SidebarNav;

}());

window.SidebarNav = SidebarNav;
