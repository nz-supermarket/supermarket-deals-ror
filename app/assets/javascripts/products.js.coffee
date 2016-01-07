# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#products').dataTable
    jQueryUI: true
    responsive: true
    autoWidth: true
    destroy: true
    stateSave: true
    dom: "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>"
    processing: true
    serverSide: true
    sAjaxSource: $('#products').data('source')

  $("#products").on "draw.dt", ->
    setTimeout (->
      $("div.green").parent().addClass "highlight-green"
      $("div.yellow").parent().addClass "highlight-yellow"
      return
    ), 500
    return
  return
