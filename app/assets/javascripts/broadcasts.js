$(document).ready(function(){
   var $remaining = $('#broadcast_char_count'),
   $messages = $remaining.next();
   var max = 1600;

   $('#broadcast_compose_message').keyup(function(){
      var chars = this.value.length,
      messages = Math.ceil(chars / 160),
      remaining =  messages * 160 - (chars  % (messages * 160) || messages * 160);
      if (chars >= max) {
         $('#broadcast_number_of_messages').text(' you have reached the limit');
      }
      else{
         $remaining.text(remaining + ' characters remaining');
         $messages.text(messages + ' message(s)');
      }

   });

   $("#broadcast_schedule").datetimepicker({
      format: "dd MM yyyy - HH:ii P",
      showMeridian: true,
      autoclose: true,
      todayBtn: true
   }),
   $("#broadcast_schedule_cp").datetimepicker({
      format: "dd MM yyyy - HH:ii P",
      showMeridian: true,
      autoclose: true,
      todayBtn: true
	}),
  $('#all_user_lists').hide();
  $("#transactionAlert").hide()
  $('#add_user_lists').click( function(event){
      event.stopPropagation();
      $('#all_user_lists').toggle();
  });
});
