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

    this.listview = this.c2.listView;
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
      console.log(data);
      self.listview.el.trigger("dataTableView:" + data);
    })
  }

  ListViewBridge.prototype._saveStateLoaded = function(){
    var self = this;
    this.listView.dataTable.on( 'stateLoaded.dt', function (e, settings, data) {
      self.sidebarNav.el.trigger('check-url');
    } );
  }

  return ListViewBridge;

}());

window.ListViewBridge = ListViewBridge;
