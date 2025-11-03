$(() => {
  $('.js-draft-loaded').each((i, e) => {
    $('.js-draft-msg').css('display', 'flex');
  });

  // Fixed post title header on scroll
  const $fixedHeader = $('.post-fixed-header');

  if ($fixedHeader.length > 0) {
    const SCROLL_THRESHOLD = 80;
    let isVisible = false;

    $(window).on('scroll', () => {
      const scrollTop = $(window).scrollTop();

      if (scrollTop > SCROLL_THRESHOLD && !isVisible) {
        // Show the fixed header
        $fixedHeader.fadeIn(150);
        isVisible = true;
      } else if (scrollTop <= SCROLL_THRESHOLD && isVisible) {
        // Hide the fixed header
        $fixedHeader.fadeOut(150);
        isVisible = false;
      }
    });
  }
});
