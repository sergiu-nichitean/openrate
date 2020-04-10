function poll_for_subscriber_import_status(import_id){
  var poll_interval = setInterval(function(){
    $.getJSON('/import_status/' + import_id, '', function(data){
      $('#import_status').html('Importing, please wait...');
      if(data.status == 'failed'){
        $('#import_status').html('Import failed due to the following errors:<br>');
        for(var i = 0; i < data.errors.length; i++){
          $('#import_status').append('Line ' + data.errors[i].line_number + ': ' + data.errors[i].errors + '<br>');
        }
        clearInterval(poll_interval);
      }else if(data.status == 'done'){
        $('#import_status').html('Subscribers imported successfully!');
        clearInterval(poll_interval);
      }
    });
  }, 1000);
}
