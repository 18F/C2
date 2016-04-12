// toggle "required" flag on Building depending on Expense Type
$(document).ready( function() {
  $(".expense-type .radio input").click(function() {
    var radio = $(this);
    var buildingPicker = $(".form-group.ncr_work_order_building_number");
    if (radio.attr("id").match(/_ba60$/)) {
      buildingPicker.removeClass("required");
      buildingPicker.find("*").removeClass("required");
    }
    else {
      buildingPicker.addClass("required");
      buildingPicker.find("*").addClass("required");
    }
  })
});
