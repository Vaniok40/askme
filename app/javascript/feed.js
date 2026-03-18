document.addEventListener('DOMContentLoaded', function () {
  const panel   = document.getElementById('sidePanel');
  const content = document.getElementById('sidePanelContent');
  const overlay = document.getElementById('sidePanelOverlay');
  const closeBtn = document.getElementById('sidePanelClose');

  if (!panel) return;

  function openPanel(postId) {
    content.innerHTML = '<div class="side-panel-loading"><i class="fa fa-spinner fa-spin"></i></div>';
    panel.classList.add('open');
    overlay.classList.add('visible');
    document.body.style.overflow = 'hidden';

    fetch('/posts/' + postId + '.json', {
      headers: { 'Accept': 'application/json' }
    })
      .then(function (r) { return r.json(); })
      .then(function (data) { renderPanel(data); })
      .catch(function () {
        content.innerHTML = '<p style="color:#c0392b;padding:20px">Failed to load post.</p>';
      });
  }

  function closePanel() {
    panel.classList.remove('open');
    overlay.classList.remove('visible');
    document.body.style.overflow = '';
  }

  function escHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function renderPanel(post) {
    var tags = post.tags.map(function (t) {
      return '<span class="post-tag">#' + escHtml(t) + '</span>';
    }).join('');

    var comments = post.comments.map(function (c) {
      return '<div class="panel-comment">' +
        '<strong>@' + escHtml(c.user.username) + '</strong>' +
        '<span class="panel-comment-date">' + escHtml(c.created_at) + '</span>' +
        '<p>' + escHtml(c.body) + '</p>' +
        '</div>';
    }).join('');

    var likeIcon  = post.liked ? 'fa-heart' : 'fa-heart-o';
    var likeClass = post.liked ? 'like-btn liked' : 'like-btn';

    var commentForm = post.current_user_signed_in
      ? '<form class="panel-comment-form" data-post-id="' + post.id + '" id="panelCommentForm">' +
          '<textarea rows="2" placeholder="Add a comment…" name="body"></textarea>' +
          '<button type="submit"><i class="fa fa-paper-plane"></i></button>' +
        '</form>'
      : '';

    content.innerHTML =
      '<div class="panel-author">' +
        '<div class="panel-avatar" style="background:' + escHtml(post.user.color) + '">' +
          escHtml(post.user.name[0].toUpperCase()) +
        '</div>' +
        '<div>' +
          '<div class="panel-author-name">' + escHtml(post.user.name) + '</div>' +
          '<div class="panel-author-username">@' + escHtml(post.user.username) + '</div>' +
        '</div>' +
      '</div>' +

      '<h2 class="panel-title">' + escHtml(post.title) + '</h2>' +

      '<div class="panel-meta">' +
        '<span><i class="fa fa-eye"></i> ' + post.views_count + '</span>' +
        '<button class="' + likeClass + '" id="panelLikeBtn" data-post-id="' + post.id + '">' +
          '<i class="fa ' + likeIcon + '"></i> ' + post.likes_count +
        '</button>' +
        '<span><i class="fa fa-comment-o"></i> ' + post.comments.length + '</span>' +
        '<span class="panel-date">' + escHtml(post.created_at) + '</span>' +
      '</div>' +

      '<div class="panel-body">' + escHtml(post.body) + '</div>' +

      (tags ? '<div class="panel-tags">' + tags + '</div>' : '') +

      '<div class="panel-comments">' +
        '<h4><i class="fa fa-comments"></i> Comments</h4>' +
        '<div id="panelCommentsList">' +
          (comments || '<p class="no-comments">No comments yet.</p>') +
        '</div>' +
        commentForm +
      '</div>';

    // Like toggle
    var likeBtn = document.getElementById('panelLikeBtn');
    if (likeBtn) {
      likeBtn.addEventListener('click', function () {
        var isLiked = likeBtn.classList.contains('liked');
        var method  = isLiked ? 'DELETE' : 'POST';
        var csrf    = document.querySelector('meta[name="csrf-token"]');

        fetch('/posts/' + post.id + '/toggle_like', {
          method: method,
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': csrf ? csrf.content : ''
          }
        })
          .then(function (r) { return r.json(); })
          .then(function (data) {
            likeBtn.classList.toggle('liked', data.liked);
            likeBtn.innerHTML =
              '<i class="fa ' + (data.liked ? 'fa-heart' : 'fa-heart-o') + '"></i> ' + data.likes_count;
          });
      });
    }

    // Inline comment submit
    var commentForm2 = document.getElementById('panelCommentForm');
    if (commentForm2) {
      commentForm2.addEventListener('submit', function (e) {
        e.preventDefault();
        var body = commentForm2.querySelector('textarea').value.trim();
        if (!body) return;
        var csrf = document.querySelector('meta[name="csrf-token"]');
        var fd   = new FormData();
        fd.append('comment[body]', body);

        fetch('/posts/' + post.id + '/comments', {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': csrf ? csrf.content : ''
          },
          body: fd
        })
          .then(function (r) { return r.json(); })
          .then(function (c) {
            var list = document.getElementById('panelCommentsList');
            var p = document.createElement('div');
            p.className = 'panel-comment';
            p.innerHTML =
              '<strong>@' + escHtml(c.user.username) + '</strong>' +
              '<span class="panel-comment-date">' + escHtml(c.created_at) + '</span>' +
              '<p>' + escHtml(c.body) + '</p>';
            var placeholder = list.querySelector('.no-comments');
            if (placeholder) placeholder.remove();
            list.appendChild(p);
            commentForm2.querySelector('textarea').value = '';
          });
      });
    }
  }

  // Open panel on post card click
  document.addEventListener('click', function (e) {
    var card = e.target.closest('.post-card');
    if (card && !e.target.closest('a, button, form')) {
      openPanel(card.dataset.postId);
    }
  });

  closeBtn && closeBtn.addEventListener('click', closePanel);
  overlay  && overlay.addEventListener('click', closePanel);

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closePanel();
  });
});
