$(document).on('turbolinks:load', function() {
  $('.broadcast-schedule input').click(function(){
    if($(this).is(':checked')){
      if($(this).val() == 'to_send'){
        $('.sent-at-field').hide();
        $('#send_or_schedule').html('Send Broadcast Now');
      }else{
        $('.sent-at-field').show();
        $('#send_or_schedule').html('Schedule Broadcast');
      }
    }
  });

  $('#send_or_schedule').click(function(e){
    e.preventDefault();
    $('#broadcast_is_draft').val('0');
    $('#broadcast_form').submit();
  });

  $('#filter_relation').change(function(){
    $('#filter_value_container').hide();
    $('#filter_operator').val('');
    if($(this).val().length > 0){
      if($(this).children('option:selected').data('type') == 'boolean'){
        $('#filter_operator option[data-not-boolean]').hide();
      }else{
        $('#filter_operator option[data-not-boolean]').show();
      }
      $('#filter_operator_container').show();
      $('#filter_operator').focus();
    }else{
      $('#filter_operator_container').hide();
    }
  });

  $('#filter_operator').change(function(){
    if($(this).val().length > 0){
      $.get('/broadcast_filter_value_selector', {
        relation: $('#filter_relation').val(),
        operator: $('#filter_operator').val()
      }, function(data){
        $('#filter_value_container').html(data).show();
        $('#filter_value').focus();
      });
    }else{
      $('#filter_value_container').hide();
    }
  });
});

function deleteFilter(broadcast_id, filter_id){
  document.location = '/broadcast_delete_filter/' + broadcast_id + '/?filter_id=' + filter_id;
}
