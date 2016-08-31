var ListViewDataTable;

ListViewDataTable = (function(){
  function ListViewDataTable(el, config) {
    this.el = $(el);
    this.defaultCols = ["ID",
      "Request",
      "Requester",
      "Price",
      "Status",
      "Submitted",
      "Building",
      "CL"];
    this.listConfig = config;
    this._setup();
    return this;
  }

  ListViewDataTable.prototype.addThClass = function(){
    this.el.find('th').each(function(i, item){
      var thValue = $(item).find('.table-header').html().trim().replace(" ", "-").toLowerCase();
      var klass = "th-value-" + thValue;
      $(this).addClass(klass);
    });
  }
  ListViewDataTable.prototype._setup = function(){
    var self = this;
    this.addThClass();
    if( this.el.length > 0 ){
      var config =  {
          // destroy: true,
          dom: 'Bfrtip',
          buttons: [
              {
                  extend: 'colvis',
                  columns: ':not(:first-child)'
              }
          ],
          columnDefs: self.listConfig,
          "paging":   false,
          "info":     false,
          stateSave:  true,
          responsive: true
      };
      this.dataTable = this.el.DataTable(config);
      this.statusColumn = this.dataTable.column(':contains(Status)');
      this._events();
      this.prepList();
      this.prepareEllipsisFields();
    }
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

    this.el.find('tbody td').hover(function(){
      if($(this).find('.ellipsis').length > 0){
        $(this).addClass('show-ellipsis');
      }
    }, function(){
      $(this).removeClass('show-ellipsis');
    })
  }

  ListViewDataTable.prototype.prepareEllipsisFields = function(el){
    this.el.find('tbody td').each(function(i, item){
      var ellipsis = $(item).find('.ellipsis');
      if ( ellipsis.length > 0 ){
        ellipsis.clone().html(ellipsis.attr('title')).removeClass('ellipsis').addClass('unellipsised').appendTo(item);
      }
    });
    this.el.find('tr').removeClass('active-row');
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
      var colCount = this.dataTable.column(i),
      col_name = this.colName(colCount);

      if(this.defaultCols.indexOf(col_name) === -1){
        colCount.visible(false)
      }
    }
  }

  ListViewDataTable.prototype.colName = function(column){
    return $(column.header()).text().replace(/^\s+|\s+$/g, "");
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
