// Add border to navigation on scroll
$(window).on('scroll', function() {
  const scrollThreshold = 70; // pixels
  const $topNav = $('.top-nav');

  if ($(window).scrollTop() > scrollThreshold) {
    $topNav.addClass('scrolled');
  } else {
    $topNav.removeClass('scrolled');
  }
});
