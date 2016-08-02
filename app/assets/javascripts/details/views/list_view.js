var ListViewDataTable;

ListViewDataTable = (function(){
  function ListViewDataTable(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ListViewDataTable.prototype._setup = function(){
    this.el.DataTable( {
        dom: 'Bfrtip',
        buttons: [
          // 'colvis'
        ],
        responsive: true
    } );
  }

  return ListViewDataTable;

}());

window.ListViewDataTable = ListViewDataTable;
