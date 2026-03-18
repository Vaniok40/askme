document.addEventListener('DOMContentLoaded', function () {
  var toggle    = document.getElementById('notifToggle');
  var panel     = document.getElementById('notifPanel');
  var closeBtn  = document.getElementById('notifPanelClose');
  var markAllBtn = document.getElementById('notifMarkAll');
  var list      = document.getElementById('notifList');
  var badge     = document.getElementById('notifBadge');
  var overlay   = document.getElementById('msgOverlay');

  if (!toggle) return;

  var csrf = window.CSRF_TOKEN || '';
  var isOpen = false;

  function apiFetch(url, opts) {
    opts = opts || {};
    opts.headers = Object.assign({ 'Accept': 'application/json', 'X-CSRF-Token': csrf }, opts.headers || {});
    return fetch(url, opts).then(function (r) { return r.json(); });
  }

  function esc(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // ── Badge ───────────────────────────────────────────────
  function refreshBadge() {
    apiFetch('/notifications/unread_count').then(function (data) {
      if (data.count > 0) {
        badge.textContent = data.count > 99 ? '99+' : data.count;
        badge.style.display = 'flex';
      } else {
        badge.style.display = 'none';
      }
    }).catch(function () {});
  }

  refreshBadge();
  setInterval(refreshBadge, 20000);

  // ── Deschide / închide panel ────────────────────────────
  function openPanel() {
    isOpen = true;
    panel.classList.add('open');
    overlay.classList.add('visible');
    loadNotifications();
  }

  function closePanel() {
    isOpen = false;
    panel.classList.remove('open');
    var msgPanel = document.getElementById('msgPanel');
    var chatWin  = document.getElementById('chatWindow');
    if (!msgPanel.classList.contains('open') && !chatWin.classList.contains('open')) {
      overlay.classList.remove('visible');
    }
  }

  toggle.addEventListener('click', function () {
    if (isOpen) { closePanel(); } else { openPanel(); }
  });
  closeBtn.addEventListener('click', closePanel);
  overlay.addEventListener('click', closePanel);

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closePanel();
  });

  // ── Încarcă notificări ──────────────────────────────────
  function loadNotifications() {
    list.innerHTML = '<div class="msg-list-loading"><i class="fa fa-spinner fa-spin"></i></div>';
    apiFetch('/notifications').then(function (notifs) {
      renderNotifications(notifs);
      refreshBadge();
    }).catch(function () {
      list.innerHTML = '<p class="msg-empty">Eroare la încărcare.</p>';
    });
  }

  function kindText(kind) {
    if (kind === 'like'    || kind === 'liked')    return '<i class="fa fa-heart notif-kind-icon notif-kind-like"></i> a apreciat postarea ta';
    if (kind === 'comment' || kind === 'commented') return '<i class="fa fa-comment notif-kind-icon notif-kind-comment"></i> a lăsat un comentariu la';
    return esc(kind);
  }

  function renderNotifications(notifs) {
    if (notifs.length === 0) {
      list.innerHTML = '<p class="msg-empty">Nicio notificare încă.</p>';
      return;
    }

    list.innerHTML = notifs.map(function (n) {
      var unreadClass = n.read ? '' : ' notif-unread';
      var title = n.notifiable_title ? ' <span class="notif-post-title">\u201c' + esc(n.notifiable_title) + '\u201d</span>' : '';
      var url   = n.notifiable_url || null;

      return '<div class="notif-item' + unreadClass + '" data-id="' + n.id + '" data-url="' + (url ? esc(url) : '') + '">' +
        '<a href="/users/' + n.actor.id + '" class="notif-avatar" style="background:' + esc(n.actor.color) + '" onclick="event.stopPropagation()">' +
          esc(n.actor.name[0].toUpperCase()) +
        '</a>' +
        '<div class="notif-body">' +
          '<div class="notif-text">' +
            '<a href="/users/' + n.actor.id + '" class="notif-actor" onclick="event.stopPropagation()">@' + esc(n.actor.username) + '</a>' +
            ' ' + kindText(n.kind) + title +
          '</div>' +
          '<div class="notif-time">' + esc(n.created_at) + '</div>' +
        '</div>' +
        (n.read ? '' : '<span class="notif-dot"></span>') +
      '</div>';
    }).join('');

    // click pe dot → marchează ca citită, fără navigare
    list.querySelectorAll('.notif-dot').forEach(function (dot) {
      dot.addEventListener('click', function (e) {
        e.stopPropagation();
        var el = dot.closest('.notif-item');
        var id = el.dataset.id;
        apiFetch('/notifications/' + id + '/mark_read', { method: 'PATCH' })
          .then(function () {
            el.classList.remove('notif-unread');
            dot.remove();
            refreshBadge();
          }).catch(function () {});
      });
    });

    // click pe restul notificării → marchează + navighează
    list.querySelectorAll('.notif-item').forEach(function (el) {
      el.addEventListener('click', function (e) {
        if (e.target.closest('.notif-dot')) return;
        var id  = el.dataset.id;
        var url = el.dataset.url;

        var markAndGo = function () {
          if (url) window.location.href = url;
        };

        if (el.classList.contains('notif-unread')) {
          apiFetch('/notifications/' + id + '/mark_read', { method: 'PATCH' })
            .then(markAndGo).catch(markAndGo);
        } else {
          markAndGo();
        }
      });
    });
  }

  // ── Marchează toate ca citite ───────────────────────────
  markAllBtn.addEventListener('click', function () {
    apiFetch('/notifications/mark_all_read', { method: 'PATCH' })
      .then(function () { loadNotifications(); })
      .catch(function () {});
  });
});
