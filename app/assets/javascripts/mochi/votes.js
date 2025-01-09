console.log("mochi-vite");
$(() => {
  $(document).on('click', '.vote-button', async evt => {
    const $tgt = $(evt.target).is('button') ? $(evt.target) : $(evt.target).parents('button');
    const $up = $tgt.find('.js-upvote-count');
    const voteType = $tgt.data('vote-type');
    const voted = $tgt.hasClass('active');
    console.log("mochi vote");

    if (voted) {
      const voteId = $tgt.attr('data-vote-id');
      const resp = await fetch(`/votes/${voteId}`, {
        method: 'DELETE',
        credentials: 'include',
        headers: { 'X-CSRF-Token': QPixel.csrfToken() }
      });
      const data = await resp.json();
      if (data.status === 'OK') {
        $up.text(`${data.upvotes + 1}`);
        $tgt.removeClass('active')
            .removeAttr('data-vote-id');
      }
      else {
        console.error('Vote delete failed');
        console.log(resp);
        QPixel.createNotification('danger', `<strong>Failed:</strong> ${data.message} (${resp.status})`);
      }
    }
    else {
      const resp = await fetch('/votes/new', {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': QPixel.csrfToken() },
        body: JSON.stringify({post_id: $tgt.data('post-id'), vote_type: voteType})
      });
      const data = await resp.json();
      if (data.status === 'modified' || data.status === 'OK') {
        $up.text(`${data.upvotes + 1}`);
        $tgt.addClass('active').attr('data-vote-id', data.vote_id);
      }
      else {
        console.error('Vote create failed');
        console.log(resp);
        QPixel.createNotification('danger', `<strong>Failed:</strong> ${data.message} (${resp.status})`);
      }
    }
  });
});
