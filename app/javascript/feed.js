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
        content.innerHTML = '<p style="color:#c0392b;padding:20px">Eroare la încărcarea postării.</p>';
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
        '<a href="/users/' + c.user.id + '" class="panel-comment-author">@' + escHtml(c.user.username) + '</a>' +
        '<span class="panel-comment-date">' + escHtml(c.created_at) + '</span>' +
        '<p>' + escHtml(c.body) + '</p>' +
        '</div>';
    }).join('');

    var likeIcon  = post.liked ? 'fa-heart' : 'fa-heart-o';
    var likeClass = post.liked ? 'like-btn liked' : 'like-btn';

    var commentForm = window.CURRENT_USER_ID
      ? '<form class="panel-comment-form" data-post-id="' + post.id + '" id="panelCommentForm">' +
          '<textarea rows="2" placeholder="Scrie un comentariu…" name="body"></textarea>' +
          '<button type="submit"><i class="fa fa-paper-plane"></i></button>' +
        '</form>'
      : '<p class="panel-login-hint"><a href="/sessions/new">Autentifică-te</a> pentru a comenta.</p>';

    var userUrl = '/users/' + post.user.id;
    content.innerHTML =
      '<a href="/posts/' + post.id + '" target="_blank" class="panel-open-page-btn">' +
        '<i class="fa fa-external-link"></i> Deschide în pagină nouă' +
      '</a>' +
      '<div class="panel-author">' +
        '<a href="' + userUrl + '" class="panel-avatar" style="background:' + escHtml(post.user.color) + '">' +
          escHtml(post.user.name[0].toUpperCase()) +
        '</a>' +
        '<div>' +
          '<a href="' + userUrl + '" class="panel-author-name">' + escHtml(post.user.name) + '</a>' +
          '<a href="' + userUrl + '" class="panel-author-username">@' + escHtml(post.user.username) + '</a>' +
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
        (window.CURRENT_USER_ID
          ? '<button class="post-forward-btn" onclick="openForwardModal(' + post.id + ')" title="Trimite în chat"><i class="fa fa-share"></i></button>'
          : '') +
      '</div>' +

      '<div class="panel-body">' + escHtml(post.body) + '</div>' +

      (post.images && post.images.length ? '<div class="panel-images">' +
        post.images.map(function (url) {
          return '<a href="' + url + '" target="_blank" class="panel-image-link">' +
            '<img src="' + url + '" class="panel-image" alt="">' +
          '</a>';
        }).join('') +
      '</div>' : '') +

      (tags ? '<div class="panel-tags">' + tags + '</div>' : '') +

      '<div class="panel-comments">' +
        '<h4><i class="fa fa-comments"></i> Comentarii</h4>' +
        '<div id="panelCommentsList">' +
          (comments || '<p class="no-comments">Niciun comentariu încă.</p>') +
        '</div>' +
        commentForm +
      '</div>';

    // Like toggle
    var likeBtn = document.getElementById('panelLikeBtn');
    if (likeBtn) {
      likeBtn.addEventListener('click', function () {
        if (!window.CURRENT_USER_ID) {
          window.showToast('Trebuie să fii autentificat pentru a da like.', 'alert');
          return;
        }
        var csrf = document.querySelector('meta[name="csrf-token"]');

        fetch('/posts/' + post.id + '/toggle_like', {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': csrf ? csrf.content : ''
          }
        })
          .then(function (r) { return r.json(); })
          .then(function (data) {
            if (data.error) {
              window.showToast(data.error, 'alert');
              return;
            }
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
        if (!window.CURRENT_USER_ID) {
          window.showToast('Trebuie să fii autentificat pentru a comenta.', 'alert');
          return;
        }
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
            if (c.error) {
              window.showToast(c.error, 'alert');
              return;
            }
            var list = document.getElementById('panelCommentsList');
            var p = document.createElement('div');
            p.className = 'panel-comment';
            p.innerHTML =
              '<a href="/users/' + c.user.id + '" class="panel-comment-author">@' + escHtml(c.user.username) + '</a>' +
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

  // Open panel on post card click (feed + my-posts)
  document.addEventListener('click', function (e) {
    if (e.target.closest('a, button, form')) return;
    var card = e.target.closest('.post-card, .my-post-card-body');
    if (card) openPanel(card.dataset.postId);
  });

  closeBtn && closeBtn.addEventListener('click', closePanel);
  overlay  && overlay.addEventListener('click', closePanel);

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closePanel();
  });
});
