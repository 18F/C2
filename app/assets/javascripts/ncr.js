$(document).ready(initializeDocument);

function initializeDocument() {
  //only enable bank account field when BA80 is selected as an expense_type
  $("input:radio[name='ncr_proposal[expense_type]']").click(function(event){
    if ($("input:radio[name='ncr_proposal[expense_type]']:checked").val() == 'BA80') {
      $('#ncr_proposal_rwa_number').attr('disabled', false);
    } else {
      $('#ncr_proposal_rwa_number').attr('disabled', true);
    }
  });

  //  #todo: use a class instead of enumerating
  $('#ncr_proposal_building_number').chosen({placeholder_text_multiple: 'If applicable, which building will the charge support?'});
  $('#ncr_proposal_office').chosen();
}
