$(() => {
  $(document).on('input', '.js-comment-field, .js-post-field', async ev => {
    ev.target.style.height = 0;
    ev.target.style.height = ev.target.scrollHeight + "px";
  });
});
