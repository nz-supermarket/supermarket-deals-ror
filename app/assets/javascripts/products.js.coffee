# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#products').dataTable
    sPaginationType: "simple_numbers"
    bJQueryUI: true
    bAutoWidth: true
    bDestroy: true
    sDom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    bProcessing: true
    bServerSide: true
    sAjaxSource: $('#products').data('source')

  $("#products").on "draw.dt", ->
    setTimeout (->
      $("div.green").parent().addClass "highlight-green"
      $("div.yellow").parent().addClass "highlight-yellow"
      return
    ), 500
    return
  return
