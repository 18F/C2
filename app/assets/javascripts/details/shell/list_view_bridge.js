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

    this.listview = new ListViewDataTable(config.listView);
    this.sidebarNav = new SidebarNav(config.sidebarNav);

    this._setupEvents();
  }

  ListViewBridge.prototype._overrideTestConfig = function(config){
    this.config = config;
  }

  ListViewBridge.prototype._setupEvents = function(){
  }


  return ListViewBridge;

}());

window.ListViewBridge = ListViewBridge;
