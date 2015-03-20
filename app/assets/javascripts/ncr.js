$(document).ready(initializeDocument);

function initializeDocument() {
  //  #todo: use a class instead of enumerating
  $('#ncr_proposal_building_number').chosen({placeholder_text_multiple: 'If applicable, which building will the charge support?'});
  $('#ncr_proposal_office').chosen();
}
