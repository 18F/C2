var ListViewDataTable;

ListViewDataTable = (function(){
  function ListViewDataTable(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ListViewDataTable.prototype._setup = function(){
    this.el.DataTable( {
        // destroy: true,
        // dom: 'Bfrtip',
        // buttons: [
          // 'colvis'
        // ],
        "paging":   false,
        "info":     false,
        responsive: true
    } );
  }

  return ListViewDataTable;

}());

window.ListViewDataTable = ListViewDataTable;
