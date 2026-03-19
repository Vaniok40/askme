/* ── Tag input pentru formularul de postare ───────────────── */
document.addEventListener('DOMContentLoaded', function () {
  var box          = document.getElementById('tagInputBox');
  var pillsWrap    = document.getElementById('tagPills');
  var input        = document.getElementById('tagInput');
  var suggestions  = document.getElementById('postTagSuggestions');
  var hiddenFields = document.getElementById('tagHiddenFields');

  if (box) initPostTagInput();

  function initPostTagInput() {
    var selected = [];
    var debounceTimer;

    if (window.POST_EXISTING_TAGS && window.POST_EXISTING_TAGS.length) {
      window.POST_EXISTING_TAGS.forEach(function (t) { addTag(t); });
    }

    function renderPills() {
      pillsWrap.innerHTML = selected.map(function (t) {
        return '<span class="tag-pill" data-id="' + t.id + '">' +
          '#' + esc(t.name) +
          '<button type="button" class="tag-pill-remove" data-id="' + t.id + '">\u00d7</button>' +
          '</span>';
      }).join('');

      pillsWrap.querySelectorAll('.tag-pill-remove').forEach(function (btn) {
        btn.addEventListener('click', function () { removeTag(parseInt(btn.dataset.id)); });
      });

      hiddenFields.innerHTML = selected.length
        ? selected.map(function (t) {
            return '<input type="hidden" name="post[tag_ids][]" value="' + t.id + '">';
          }).join('')
        : '<input type="hidden" name="post[tag_ids][]" value="">';
    }

    function addTag(tag) {
      if (selected.find(function (t) { return t.id === tag.id; })) return;
      selected.push(tag);
      renderPills();
      input.value = '';
      hideSuggestions();
    }

    function removeTag(id) {
      selected = selected.filter(function (t) { return t.id !== id; });
      renderPills();
    }

    function fetchSuggestions(q) {
      fetch('/tags/search?q=' + encodeURIComponent(q), { headers: { Accept: 'application/json' } })
        .then(function (r) { return r.json(); })
        .then(function (tags) { renderSuggestions(tags, q); })
        .catch(function () {});
    }

    function renderSuggestions(tags, q) {
      var filtered = tags.filter(function (t) {
        return !selected.find(function (s) { return s.id === t.id; });
      });

      var items = filtered.map(function (t) {
        return '<li class="tag-suggestion-item" data-id="' + t.id + '" data-name="' + esc(t.name) + '">#' + esc(t.name) + '</li>';
      });

      /* Dacă textul tastat nu se potrivește exact cu niciun tag existent, oferă opțiunea de a-l crea */
      var normalizedQ = (q || '').trim().toLowerCase().replace(/^#/, '').replace(/[^a-z0-9_]/g, '');
      var exactMatch = normalizedQ && tags.find(function (t) { return t.name === normalizedQ; });
      var alreadySelected = normalizedQ && selected.find(function (s) { return s.name === normalizedQ; });
      if (normalizedQ && !exactMatch && !alreadySelected) {
        items.push('<li class="tag-suggestion-item tag-suggestion-create" data-new="true" data-name="' + esc(normalizedQ) + '"><i class="fa fa-plus"></i> Creează <strong>#' + esc(normalizedQ) + '</strong></li>');
      }

      if (!items.length) { hideSuggestions(); return; }

      suggestions.innerHTML = items.join('');
      suggestions.style.display = 'block';

      suggestions.querySelectorAll('.tag-suggestion-item').forEach(function (li) {
        li.addEventListener('mousedown', function (e) {
          e.preventDefault();
          if (li.dataset.new) {
            createAndAddTag(li.dataset.name);
          } else {
            addTag({ id: parseInt(li.dataset.id), name: li.dataset.name });
          }
        });
      });
    }

    function createAndAddTag(name) {
      var meta = document.querySelector('meta[name="csrf-token"]');
      var token = meta ? meta.content : '';
      fetch('/tags', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-CSRF-Token': token },
        body: JSON.stringify({ name: name })
      })
        .then(function (r) { return r.json(); })
        .then(function (tag) { if (tag.id) addTag(tag); })
        .catch(function () {});
    }

    function hideSuggestions() {
      suggestions.style.display = 'none';
      suggestions.innerHTML = '';
    }

    input.addEventListener('input', function () {
      clearTimeout(debounceTimer);
      var q = input.value.trim();
      debounceTimer = setTimeout(function () { fetchSuggestions(q); }, 200);
    });

    input.addEventListener('focus', function () {
      fetchSuggestions(input.value.trim());
    });

    input.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        var first = suggestions.querySelector('.tag-suggestion-item');
        if (first) {
          if (first.dataset.new) {
            createAndAddTag(first.dataset.name);
          } else {
            addTag({ id: parseInt(first.dataset.id), name: first.dataset.name });
          }
        } else {
          /* Nicio sugestie — încearcă să creeze direct din ce e scris */
          var q = input.value.trim().toLowerCase().replace(/^#/, '').replace(/[^a-z0-9_]/g, '');
          if (q) createAndAddTag(q);
        }
      }
      if (e.key === 'Escape') hideSuggestions();
    });

    box.addEventListener('click', function () { input.focus(); });

    document.addEventListener('click', function (e) {
      if (!box.contains(e.target)) hideSuggestions();
    });

    renderPills();
  }

  /* ── Tag search în feed ─────────────────────────────────── */
  var searchInput = document.getElementById('tagSearchInput');
  var feedSuggestions = document.getElementById('tagSuggestions');
  var activeTags  = document.getElementById('feedActiveTags');

  if (searchInput) initFeedTagSearch();

  function initFeedTagSearch() {
    var active = [];
    var debounceTimer;

    /* Preîncarcă tagurile active din URL */
    new URLSearchParams(window.location.search).getAll('tag_ids[]').forEach(function (id) {
      var pill = activeTags && activeTags.querySelector('[data-id="' + id + '"]');
      if (pill) active.push({ id: parseInt(id), name: pill.querySelector('.feed-active-tag-name').textContent.replace(/^#/, '') });
    });

    function fetchSuggestions(q) {
      fetch('/tags/search?q=' + encodeURIComponent(q), { headers: { Accept: 'application/json' } })
        .then(function (r) { return r.json(); })
        .then(function (tags) { renderSuggestions(tags); })
        .catch(function () {});
    }

    function renderSuggestions(tags) {
      var filtered = tags.filter(function (t) {
        return !active.find(function (a) { return a.id === t.id; });
      });
      if (!filtered.length) { hideSuggestions(); return; }

      feedSuggestions.innerHTML = filtered.map(function (t) {
        return '<li class="tag-suggestion-item" data-id="' + t.id + '" data-name="' + esc(t.name) + '">#' + esc(t.name) + '</li>';
      }).join('');
      feedSuggestions.style.display = 'block';

      feedSuggestions.querySelectorAll('.tag-suggestion-item').forEach(function (li) {
        li.addEventListener('mousedown', function (e) {
          e.preventDefault();
          addActiveTag({ id: parseInt(li.dataset.id), name: li.dataset.name });
        });
      });
    }

    function hideSuggestions() {
      feedSuggestions.style.display = 'none';
      feedSuggestions.innerHTML = '';
    }

    function addActiveTag(tag) {
      if (active.find(function (a) { return a.id === tag.id; })) return;
      active.push(tag);
      searchInput.value = '';
      hideSuggestions();
      applyFilter();
    }

    function removeActiveTag(id) {
      active = active.filter(function (a) { return a.id !== id; });
      applyFilter();
    }

    function applyFilter() {
      var base = window.location.pathname;
      var parts = active.map(function (t) { return 'tag_ids[]=' + t.id; });
      /* Preserve the text search query if present */
      var q = (document.getElementById('postSearchInput') || {}).value;
      if (q && q.trim()) parts.push('q=' + encodeURIComponent(q.trim()));
      window.location.href = base + (parts.length ? '?' + parts.join('&') : '');
    }

    if (activeTags) {
      activeTags.querySelectorAll('.feed-active-tag-remove').forEach(function (btn) {
        var pill = btn.closest('.feed-active-tag');
        btn.addEventListener('click', function () {
          removeActiveTag(parseInt(pill.dataset.id));
        });
      });
    }

    searchInput.addEventListener('input', function () {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function () { fetchSuggestions(searchInput.value.trim()); }, 200);
    });

    searchInput.addEventListener('focus', function () {
      fetchSuggestions(searchInput.value.trim());
    });

    searchInput.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') hideSuggestions();
    });

    document.addEventListener('click', function (e) {
      if (!e.target.closest('#feedTagSearch')) hideSuggestions();
    });
  }

  function esc(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
});

/* ── Image upload preview ─────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function () {
  var input   = document.getElementById('imageInput');
  var preview = document.getElementById('imagePreviewList');
  if (!input || !preview) return;

  input.addEventListener('change', function () {
    preview.innerHTML = '';
    Array.from(input.files).slice(0, 5).forEach(function (file) {
      var reader = new FileReader();
      reader.onload = function (e) {
        var item = document.createElement('div');
        item.className = 'image-preview-item';
        item.innerHTML = '<img src="' + e.target.result + '" class="image-preview-thumb" alt="">' +
          '<span class="image-preview-name">' + file.name + '</span>';
        preview.appendChild(item);
      };
      reader.readAsDataURL(file);
    });
  });

  var area = document.getElementById('imageUploadArea');
  if (area) {
    area.addEventListener('dragover', function (e) { e.preventDefault(); area.classList.add('drag-over'); });
    area.addEventListener('dragleave', function () { area.classList.remove('drag-over'); });
    area.addEventListener('drop', function (e) {
      e.preventDefault();
      area.classList.remove('drag-over');
      var dt = new DataTransfer();
      Array.from(e.dataTransfer.files).forEach(function (f) { dt.items.add(f); });
      input.files = dt.files;
      input.dispatchEvent(new Event('change'));
    });
  }
});
