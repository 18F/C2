var ListViewBridge;

ListViewBridge = (function() {

  function ListViewBridge(c2, config){
    this.c2 = c2;
    config = config || {};
    this.config = {
      listView:       "#tabular-data",
      sidebarNav:     "#sidebar-home"
    }
    this._overrideTestConfig(config);
    this._blastOff();
  }

  ListViewBridge.prototype._blastOff = function(){
    var config = this.config;

    this.listView = this.c2.listView;
    this.sidebarNav = this.c2.sidebarNav;

    this._setupEvents();
    this._saveStateLoaded();
  }


  ListViewBridge.prototype._overrideTestConfig = function(config){
    this.config = config;
  }

  ListViewBridge.prototype._setupEvents = function(){
    var self = this;
    this.sidebarNav.el.on('sidebar:button', function(event, data){
      self.listView.el.trigger("dataTableView:" + data);
    })
  }

  ListViewBridge.prototype._saveStateLoaded = function(){
    this.sidebarNav.el.trigger('refresh-list');
  }

  return ListViewBridge;

}());

window.ListViewBridge = ListViewBridge;
