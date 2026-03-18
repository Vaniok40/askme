// Toast notifications — top-right, auto-dismiss
(function () {
  var container = null;

  function getContainer() {
    if (!container) {
      container = document.getElementById('toastContainer');
      if (!container) {
        container = document.createElement('div');
        container.id = 'toastContainer';
        document.body.appendChild(container);
      }
    }
    return container;
  }

  window.showToast = function (message, type) {
    type = type || 'notice';
    var c = getContainer();

    var toast = document.createElement('div');
    toast.className = 'toast-msg toast-' + type;
    toast.innerHTML =
      '<span class="toast-text">' + String(message).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;') + '</span>' +
      '<button class="toast-close" aria-label="Închide">&times;</button>';

    toast.querySelector('.toast-close').addEventListener('click', function () {
      dismiss(toast);
    });

    c.appendChild(toast);

    // trigger reflow so transition plays
    toast.getBoundingClientRect();
    toast.classList.add('toast-visible');

    var timer = setTimeout(function () { dismiss(toast); }, 4000);
    toast._timer = timer;
  };

  function dismiss(toast) {
    clearTimeout(toast._timer);
    toast.classList.remove('toast-visible');
    toast.addEventListener('transitionend', function () {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, { once: true });
  }

  // Convert server-side flash messages rendered as data attributes on #flashData
  document.addEventListener('DOMContentLoaded', function () {
    var flashEl = document.getElementById('flashData');
    if (!flashEl) return;
    var messages = JSON.parse(flashEl.dataset.flash || '[]');
    messages.forEach(function (item) {
      window.showToast(item.message, item.type);
    });
  });
})();
