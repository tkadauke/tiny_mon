function apply_table_events() {
  $("a.select-all").click(function(event) {
    $('table input[type="checkbox"]').prop('checked', true)
    event.preventDefault()
  })

  $("a.select-none").click(function(event) {
    $('table input[type="checkbox"]').prop('checked', false)
    event.preventDefault()
  })

  $("a.select-invert").click(function(event) {
    $('table input[type="checkbox"]').each(function(index) {
      $(this).prop('checked', !$(this).prop('checked'))
    })
    event.preventDefault()
  })
}

$(apply_table_events)
