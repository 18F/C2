var ListViewDataTable;

ListViewDataTable = (function(){
  function ListViewDataTable(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ListViewDataTable.prototype._setup = function(){
    this.dataTable = this.el.DataTable( {
        // destroy: true,
        dom: 'Bfrtip',
        buttons: [
            {
                extend: 'colvis',
                columns: ':not(:first-child)'
            }
        ],
        "paging":   false,
        "info":     false,
        responsive: true
    } );
    this._events();
  }

  ListViewDataTable.prototype._events = function(){
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

  ListViewDataTable.prototype.viewPending = function(){
    this.dataTable.column(':contains(Status)').search('Waiting for review from').draw();
  }

  ListViewDataTable.prototype.viewCanceled = function(){
    this.dataTable.column(':contains(Status)').search('Canceled').draw();
  }

  ListViewDataTable.prototype.viewAll = function(){
    this.dataTable.column(':contains(Status)').search('').draw();
  }

  ListViewDataTable.prototype.viewCompleted = function(){
    this.dataTable.column(':contains(Status)').search('Completed').draw();
  }

  return ListViewDataTable;

}());

window.ListViewDataTable = ListViewDataTable;
