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

$(function(){
 $('#selector').change(function(){
   $('.colors').hide();
   var items = [];
   var children = $(this).children();
   try{
     for(child in children){
       var value = $(children[child]).val();
       if (value != "") items.push(value);
     }
   }catch(e){};
   var selected = $(this).val();
   var matched = items.indexOf(selected);
   if (matched != 0){
     $('#all_user_lists').children().prop('disabled', true).prop('required', false);
     $('#data1').prop('disabled', false).prop('required', true);
     $('#data2').prop('disabled', false);
   }else {
     $('#data1').prop('disabled', true).prop('required', false);
     $('#data2').prop('disabled', true);
     //$('#all_user_lists').children().prop('disabled', false).prop('required', true);
   }
   $('#' + selected).show();
 });
});
