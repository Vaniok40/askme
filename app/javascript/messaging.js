document.addEventListener('DOMContentLoaded', function () {
  // ── Elemente DOM ────────────────────────────────────────
  var toggle      = document.getElementById('msgPanelToggle');
  var panel       = document.getElementById('msgPanel');
  var panelClose  = document.getElementById('msgPanelClose');
  var msgList     = document.getElementById('msgList');
  var msgSearch   = document.getElementById('msgSearch');
  var msgBadge    = document.getElementById('msgBadge');
  var overlay     = document.getElementById('msgOverlay');

  var chatWindow  = document.getElementById('chatWindow');
  var chatClose   = document.getElementById('chatWindowClose');
  var chatHeader  = document.getElementById('chatHeaderUser');
  var chatMsgs    = document.getElementById('chatMessages');
  var chatInput   = document.getElementById('chatInput');
  var chatSendBtn = document.getElementById('chatSendBtn');

  if (!toggle) return; // utilizator nelogat

  var csrf        = window.CSRF_TOKEN || '';
  var activeConvoId   = null;
  var lastMsgId       = 0;
  var pollTimer       = null;
  var allConvos       = [];

  // ── Helpers ──────────────────────────────────────────────
  function esc(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function apiFetch(url, opts) {
    opts = opts || {};
    opts.headers = Object.assign({ 'Accept': 'application/json', 'X-CSRF-Token': csrf }, opts.headers || {});
    return fetch(url, opts).then(function (r) { return r.json(); });
  }

  // ── Badge mesaje necitite ─────────────────────────────────
  function refreshBadge() {
    apiFetch('/messages/unread_count').then(function (data) {
      if (data.count > 0) {
        msgBadge.textContent = data.count > 99 ? '99+' : data.count;
        msgBadge.style.display = 'flex';
      } else {
        msgBadge.style.display = 'none';
      }
    }).catch(function () {});
  }

  refreshBadge();
  setInterval(refreshBadge, 15000);

  // ── Deschide / închide panel stânga ──────────────────────
  function openPanel() {
    panel.classList.add('open');
    overlay.classList.add('visible');
    loadConversations();
  }

  function closePanel() {
    panel.classList.remove('open');
    if (!chatWindow.classList.contains('open')) {
      overlay.classList.remove('visible');
    }
  }

  toggle.addEventListener('click', function () {
    if (panel.classList.contains('open')) {
      closePanel();
    } else {
      openPanel();
    }
  });

  panelClose.addEventListener('click', closePanel);

  // ── Închide chat ──────────────────────────────────────────
  function closeChat() {
    chatWindow.classList.remove('open');
    if (!panel.classList.contains('open')) {
      overlay.classList.remove('visible');
    }
    clearInterval(pollTimer);
    activeConvoId = null;
    lastMsgId = 0;
  }

  chatClose.addEventListener('click', closeChat);
  overlay.addEventListener('click', function () {
    closePanel();
    closeChat();
  });

  // ── Încarcă lista conversații ─────────────────────────────
  function loadConversations() {
    msgList.innerHTML = '<div class="msg-list-loading"><i class="fa fa-spinner fa-spin"></i></div>';
    apiFetch('/conversations').then(function (data) {
      allConvos = data;
      renderConvoList(data);
    }).catch(function () {
      msgList.innerHTML = '<p class="msg-empty">Eroare la încărcarea conversațiilor.</p>';
    });
  }

  function renderConvoList(convos) {
    if (convos.length === 0) {
      msgList.innerHTML = '<p class="msg-empty">Nicio conversație încă.</p>';
      return;
    }
    msgList.innerHTML = convos.map(function (c) {
      var u = c.other_user;
      var last = c.last_message ? esc(c.last_message.body) : '<em>Fără mesaje</em>';
      var unread = c.unread_count > 0
        ? '<span class="msg-unread-dot">' + c.unread_count + '</span>'
        : '';
      var active = activeConvoId === c.id ? ' active' : '';
      return '<div class="msg-convo-item' + active + '" data-id="' + c.id + '" ' +
        'data-name="' + esc(u.name) + '" ' +
        'data-username="' + esc(u.username) + '" ' +
        'data-color="' + esc(u.color) + '">' +
        '<div class="msg-avatar" style="background:' + esc(u.color) + '">' + esc(u.name[0].toUpperCase()) + '</div>' +
        '<div class="msg-convo-info">' +
          '<a href="/users/' + u.id + '" class="msg-convo-name" onclick="event.stopPropagation()">' + esc(u.name) + ' <span class="msg-convo-username">@' + esc(u.username) + '</span></a>' +
          '<div class="msg-convo-last">' + last + '</div>' +
        '</div>' +
        unread +
        '</div>';
    }).join('');

    msgList.querySelectorAll('.msg-convo-item').forEach(function (el) {
      el.addEventListener('click', function () {
        openChat(
          parseInt(el.dataset.id),
          el.dataset.name,
          el.dataset.username,
          el.dataset.color
        );
        // marchează activ
        msgList.querySelectorAll('.msg-convo-item').forEach(function (x) { x.classList.remove('active'); });
        el.classList.add('active');
        // resetează badge unread pe item
        var dot = el.querySelector('.msg-unread-dot');
        if (dot) dot.remove();
      });
    });
  }

  // ── Caută în lista de conversații ────────────────────────
  msgSearch.addEventListener('input', function () {
    var q = msgSearch.value.toLowerCase();
    var filtered = allConvos.filter(function (c) {
      return c.other_user.name.toLowerCase().includes(q) ||
             c.other_user.username.toLowerCase().includes(q);
    });
    renderConvoList(filtered);
  });

  // ── Deschide fereastra de chat ────────────────────────────
  function openChat(convoId, name, username, color) {
    activeConvoId = convoId;
    lastMsgId = 0;
    clearInterval(pollTimer);

    // header
    var convoUserUrl = '/users/' + convoId;
    // găsim id-ul real al utilizatorului din lista conversațiilor
    var convoObj = allConvos.find(function(c) { return c.id === convoId; });
    if (convoObj) convoUserUrl = '/users/' + convoObj.other_user.id;

    chatHeader.innerHTML =
      '<a href="' + convoUserUrl + '" class="chat-avatar" style="background:' + esc(color) + '">' + esc(name[0].toUpperCase()) + '</a>' +
      '<div>' +
        '<a href="' + convoUserUrl + '" class="chat-header-name">' + esc(name) + '</a>' +
        '<a href="' + convoUserUrl + '" class="chat-header-username">@' + esc(username) + '</a>' +
      '</div>';

    chatMsgs.innerHTML = '<div class="chat-loading"><i class="fa fa-spinner fa-spin"></i></div>';
    chatWindow.classList.add('open');
    overlay.classList.add('visible');

    // dacă panelul e deschis pe mobil îl închidem
    if (window.innerWidth < 700) closePanel();

    fetchMessages();
    pollTimer = setInterval(pollMessages, 3000);
    chatInput.focus();
  }

  // ── Fetch mesaje inițial ──────────────────────────────────
  function fetchMessages() {
    apiFetch('/conversations/' + activeConvoId + '/messages')
      .then(function (msgs) {
        renderMessages(msgs, true);
        if (msgs.length > 0) lastMsgId = msgs[msgs.length - 1].id;
        refreshBadge();
      }).catch(function () {
        chatMsgs.innerHTML = '<p class="msg-empty">Eroare la încărcarea mesajelor.</p>';
      });
  }

  // ── Polling mesaje noi ────────────────────────────────────
  function pollMessages() {
    if (!activeConvoId) return;
    apiFetch('/conversations/' + activeConvoId + '/messages/poll?after=' + lastMsgId + '&conversation_id=' + activeConvoId)
      .then(function (msgs) {
        if (msgs.length > 0) {
          appendMessages(msgs);
          lastMsgId = msgs[msgs.length - 1].id;
          refreshBadge();
          // reîncarcă lista conversații pentru a actualiza last_message
          loadConversations();
        }
      }).catch(function () {});
  }

  // ── Renderează toate mesajele ─────────────────────────────
  function renderMessages(msgs, clear) {
    if (clear) chatMsgs.innerHTML = '';
    if (msgs.length === 0 && clear) {
      chatMsgs.innerHTML = '<p class="chat-no-msgs">Niciun mesaj încă. Începe conversația!</p>';
      return;
    }
    appendMessages(msgs);
  }

  function appendMessages(msgs) {
    // dacă există placeholder "niciun mesaj" îl ștergem
    var placeholder = chatMsgs.querySelector('.chat-no-msgs');
    if (placeholder) placeholder.remove();

    var atBottom = chatMsgs.scrollHeight - chatMsgs.scrollTop - chatMsgs.clientHeight < 60;

    msgs.forEach(function (m) {
      var el = document.createElement('div');
      el.className = 'chat-msg ' + (m.mine ? 'chat-msg-mine' : 'chat-msg-theirs');
      el.innerHTML =
        '<div class="chat-bubble">' + esc(m.body) + '</div>' +
        '<div class="chat-msg-time">' + esc(m.created_at) + '</div>';
      chatMsgs.appendChild(el);
    });

    if (atBottom) chatMsgs.scrollTop = chatMsgs.scrollHeight;
  }

  // ── Trimite mesaj ─────────────────────────────────────────
  function sendMessage() {
    var body = chatInput.value.trim();
    if (!body || !activeConvoId) return;

    chatInput.value = '';
    chatInput.style.height = 'auto';

    var fd = new FormData();
    fd.append('body', body);

    apiFetch('/conversations/' + activeConvoId + '/messages', {
      method: 'POST',
      body: fd
    }).then(function (msg) {
      if (msg.error) return;
      appendMessages([msg]);
      lastMsgId = msg.id;
      loadConversations();
    }).catch(function () {});
  }

  chatSendBtn.addEventListener('click', sendMessage);

  chatInput.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  });

  // Auto-resize textarea
  chatInput.addEventListener('input', function () {
    chatInput.style.height = 'auto';
    chatInput.style.height = Math.min(chatInput.scrollHeight, 120) + 'px';
  });

  // ── Buton "Trimite mesaj" de pe profil ────────────────────
  var startChatBtn = document.getElementById('startChatBtn');
  if (startChatBtn) {
    startChatBtn.addEventListener('click', function () {
      var recipientId = startChatBtn.dataset.recipientId;
      var name        = startChatBtn.dataset.recipientName;
      var username    = startChatBtn.dataset.recipientUsername;
      var color       = startChatBtn.dataset.recipientColor;

      var fd = new FormData();
      fd.append('recipient_id', recipientId);

      apiFetch('/conversations', { method: 'POST', body: fd })
        .then(function (data) {
          openPanel();
          openChat(data.id, name, username, color);
        });
    });
  }

  // ── Escape închide ambele ─────────────────────────────────
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      closeChat();
      closePanel();
    }
  });
});
