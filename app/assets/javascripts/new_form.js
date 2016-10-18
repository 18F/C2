$(document).ready(function(){
  $("form [required='required']").on("keypress change",function(e){
    var formComplete = true;
    $("form [required='required']").each(function(){
      if(!$(this).val().length && formComplete){
        formComplete = false;
      }
    });
    if(formComplete){
      $(".action-bar-container input[type='submit']").addClass("form-complete")
    }
  })
});