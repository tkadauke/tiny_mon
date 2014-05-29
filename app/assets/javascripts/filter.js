$(function() {
  $('.dropdown-menu input, .dropdown-menu select, .dropdown-menu label').click(function(e) {
    e.stopPropagation();
  });
});
