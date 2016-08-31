var ListConfig;

ListConfig = (function(){
  function ListConfig() {
    var config = [
      {
        targets: "th-value-id"
      },
      {
        targets: "th-value-request",
        "width": "230px"
      },
      {
        targets: "th-value-requester",
        "width": "200px",
        render: $.fn.dataTable.render.ellipsis( 25 )
      },
      {
        targets: "th-value-status",
        "width": "150px",
        render: $.fn.dataTable.render.ellipsis( 25 )
      },
      {
        targets: "th-value-submitted",
        "width": "150px"
      },
      {
        "targets": 'th-value-price',
        "width": "100px"
      },
      {
        targets: "th-value-price",
        "width": "170px"
      },
      {
        targets: "th-value-urgency"
      },
      {
        targets: "th-value-purchase",
        "width": "20%"
      },
      {
        targets: "th-value-vendor",
        "width": "200px",
        render: $.fn.dataTable.render.ellipsis( 25 )
      },
      {
        targets: "th-value-expense",
        "width": "60px"
      },
      {
        targets: "th-value-building",
        "width": "400px",
        render: $.fn.dataTable.render.ellipsis( 25 )
      },
      {
        targets: "th-value-rwa",
        "width": "95px"
      },
      {
        targets: "th-value-wo",
        "width": "95px"
      },
      {
        targets: "th-value-direct"
      },
      {
        targets: "th-value-cl",
        "width": "95px"
      },
      {
        targets: "th-value-function",
        "width": "20%"
      },
      {
        targets: "th-value-soc",
        "width": "95px",
      }
    ]
    return config;
  }
  return ListConfig;

}());

window.ListConfig = ListConfig;
