// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
//= require jquery
//= require jquery_ujs
//= require base
//--- Angle
//= require_tree ./angle/
//= require time_picker
//= require echarts.min
//= require broadcasts


$('.payment').click('ajax:complete', function() {
  $(this).closest('tr').fadeOut();
  setTimeout(function(){
    $('#notice').html("")
  }, 1000)
});
