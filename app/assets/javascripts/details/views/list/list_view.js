var ListViewDataTable;

ListViewDataTable = (function(){
  function ListViewDataTable(el) {
    this.el = $(el);
    this._setup();
    return this;
  }

  ListViewDataTable.prototype._setup = function(){
    var self = this;
    if( this.el.length > 0 ){
      this.dataTable = this.el.DataTable( {
          // destroy: true,
          dom: 'Bfrtip',
          buttons: [
              {
                  extend: 'colvis',
                  columns: ':not(:first-child)'
              }
          ],
          columnDefs: self.renderConfig,
          "paging":   false,
          "info":     false,
          stateSave: true,
          responsive: true
      } );
      this.statusColumn = this.dataTable.column(':contains(Status)');
      this._events();
      this.prepList();
    }
  }

  ListViewDataTable.prototype.renderConfig = function(){
    var config = [ 
    {
      targets: 2,
      render: $.fn.dataTable.render.ellipsis( 20 )
    },
    {
      targets: 3,
      render: $.fn.dataTable.render.ellipsis( 20 )
    },
    {
      targets: 4,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 5,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 6,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 7,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 8,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 9,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 10,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 11,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 12,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 13,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 14,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }, 
    {
      targets: 15,
      render: $.fn.dataTable.render.ellipsis( 20 )
    }];
    return config;
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
    this.el.on('click', 'tbody tr *', function(){
      var el = this;
      if(!$(el).parents('.public_id').length && !$(el).hasClass('public_id')){
        var link = $(this).closest('tr').find('a').first().attr('href');
        if(link){
          window.location.href = link;  
        }
      }
    });
    this.el.find('tr').mouseenter(function(){
      var el = $(this).closest('tr');
      self.removeActiveRow(el);
      self.addActiveRow(el);
    }).mouseleave(function(){
      var el = $(this).closest('tr');
      self.removeActiveRow(el);
    });
  }

  ListViewDataTable.prototype.removeActiveRow = function(el){
    this.el.find('tr').removeClass('active-row');
  }

  ListViewDataTable.prototype.addActiveRow = function(el){
    $(el).addClass('active-row');
  }

  ListViewDataTable.prototype.viewPending = function(){
    this.statusColumn.search('Waiting for review from').draw();
  }

  ListViewDataTable.prototype.viewCanceled = function(){
    this.statusColumn.search('Canceled').draw();
  }

  ListViewDataTable.prototype.viewAll = function(){
    this.statusColumn.search('').draw();
  }

  ListViewDataTable.prototype.viewCompleted = function(){
    this.statusColumn.search('Completed').draw();
  }

  ListViewDataTable.prototype.hideExtraCols = function(){
    for(i = 0; i < this.dataTable.columns()[0].length; i++){
      var colCount = this.dataTable.column(i);
      if(i > 5){
        colCount.visible(false);
      }
    }
  }
  ListViewDataTable.prototype.prepList = function(){
    if (typeof(Storage) !== "undefined") {
      if ( !localStorage.savedColState || localStorage.savedColState !== "setup" ){
        this.hideExtraCols();
        localStorage.setItem('savedColState', 'setup');
      }
    } else {
      this.hideExtraCols();
    }
  }

  return ListViewDataTable;

}());

window.ListViewDataTable = ListViewDataTable;
