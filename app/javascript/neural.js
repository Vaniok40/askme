document.addEventListener('DOMContentLoaded', function () {
  var canvas = document.getElementById('neuralCanvas');
  var svg    = document.getElementById('neuralSvg');
  if (!canvas || !svg) return;

  var nodes = Array.from(canvas.querySelectorAll('.neural-node'));
  if (!nodes.length) return;

  var W, H;
  var positions  = [];
  var lines      = [];
  var raf;
  var MAX_DIST   = 260;
  var SIZES      = ['sm', 'md', 'md', 'lg', 'md', 'sm'];
  var NODE_SIZES = { sm: 46, md: 58, lg: 70 };
  var PADDING    = 80;

  nodes.forEach(function (node, i) {
    var sizeKey = SIZES[i % SIZES.length];
    node.setAttribute('data-size', sizeKey);
    node.style.setProperty('--node-size', NODE_SIZES[sizeKey] + 'px');
  });

  function layout() {
    W = canvas.offsetWidth;

    var cols  = Math.max(3, Math.round(Math.sqrt(nodes.length * 1.6)));
    var rows  = Math.ceil(nodes.length / cols);
    var cellW = (W - PADDING * 2) / cols;
    var cellH = 160;
    H = rows * cellH + PADDING * 2;
    canvas.style.height = H + 'px';
    svg.setAttribute('viewBox', '0 0 ' + W + ' ' + H);

    nodes.forEach(function (node, i) {
      var col = i % cols;
      var row = Math.floor(i / cols);
      var sizeKey = node.getAttribute('data-size') || 'md';
      var r = NODE_SIZES[sizeKey] / 2;

      var x = PADDING + col * cellW + cellW / 2 + randBetween(-cellW * 0.25, cellW * 0.25);
      var y = PADDING + row * cellH + cellH / 2 + randBetween(-cellH * 0.2, cellH * 0.2);

      x = Math.max(r + 4, Math.min(W - r - 4, x));
      y = Math.max(r + 4, Math.min(H - r - 4, y));

      positions[i] = {
        x:  x,
        y:  y,
        ox: x,
        oy: y,
        vx: randBetween(-0.08, 0.08),
        vy: randBetween(-0.08, 0.08),
        r:  r
      };

      applyPos(node, positions[i]);

      if (y < 120) {
        node.classList.add('tooltip-below');
      } else {
        node.classList.remove('tooltip-below');
      }
    });

    buildLines();
  }

  function applyPos(node, p) {
    node.style.left = (p.x - p.r) + 'px';
    node.style.top  = (p.y - p.r) + 'px';
  }

  function buildLines() {
    svg.innerHTML = '';
    lines = [];

    nodes.forEach(function (_, i) {
      var distances = [];
      nodes.forEach(function (_, j) {
        if (i === j) return;
        var dx = positions[i].x - positions[j].x;
        var dy = positions[i].y - positions[j].y;
        distances.push({ j: j, d: Math.sqrt(dx * dx + dy * dy) });
      });
      distances.sort(function (a, b) { return a.d - b.d; });

      var connect = Math.min(3, distances.length);
      for (var k = 0; k < connect; k++) {
        var j = distances[k].j;
        if (lines.find(function (l) { return (l.i === i && l.j === j) || (l.i === j && l.j === i); })) continue;
        if (distances[k].d > MAX_DIST) continue;
        var line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        svg.appendChild(line);
        lines.push({ i: i, j: j, el: line });
      }
    });

    updateLines();
  }

  function updateLines() {
    lines.forEach(function (l) {
      var a = positions[l.i];
      var b = positions[l.j];
      var dx = b.x - a.x;
      var dy = b.y - a.y;
      var d  = Math.sqrt(dx * dx + dy * dy);
      var alpha = Math.max(0, 1 - d / MAX_DIST);
      l.el.setAttribute('x1', a.x);
      l.el.setAttribute('y1', a.y);
      l.el.setAttribute('x2', b.x);
      l.el.setAttribute('y2', b.y);
      l.el.style.opacity = (alpha * 0.85).toFixed(2);
    });
  }

  function animate() {
    nodes.forEach(function (node, i) {
      var p = positions[i];
      p.x += p.vx;
      p.y += p.vy;

      var ORBIT = 40;
      var dx0 = p.x - p.ox;
      var dy0 = p.y - p.oy;
      var dist0 = Math.sqrt(dx0 * dx0 + dy0 * dy0);
      if (dist0 > ORBIT) {
        var pull = (dist0 - ORBIT) * 0.012;
        p.vx -= (dx0 / dist0) * pull;
        p.vy -= (dy0 / dist0) * pull;
      }

      p.vx += randBetween(-0.001, 0.001);
      p.vy += randBetween(-0.001, 0.001);

      var speed = Math.sqrt(p.vx * p.vx + p.vy * p.vy);
      if (speed > 0.05) { p.vx *= 0.05 / speed; p.vy *= 0.05 / speed; }
      if (speed < 0.003) { p.vx += randBetween(-0.003, 0.003); p.vy += randBetween(-0.003, 0.003); }

      applyPos(node, p);

      if (p.y < 120) {
        node.classList.add('tooltip-below');
      } else {
        node.classList.remove('tooltip-below');
      }
    });

    updateLines();
    raf = requestAnimationFrame(animate);
  }

  var resizeTimer;
  window.addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function () {
      cancelAnimationFrame(raf);
      layout();
      raf = requestAnimationFrame(animate);
    }, 200);
  });

  layout();
  raf = requestAnimationFrame(animate);

  function currentPostIds() {
    return nodes.map(function (n) { return n.dataset.postId; }).join(',');
  }

  function buildNodeHtml(post) {
    var tagsHtml = post.tags.length
      ? '<span class="neural-tooltip-tags">' + post.tags.map(function (t) { return '#' + t; }).join(' ') + '</span>'
      : '';
    return '<div class="neural-node" data-post-id="' + post.id + '" style="--node-color:' + post.user.color + '">' +
      '<div class="neural-node-inner">' +
      '<div class="neural-node-avatar" style="background:' + post.user.color + '">' +
      post.user.name[0].toUpperCase() +
      '</div></div>' +
      '<div class="neural-tooltip">' +
      '<div class="neural-tooltip-title">' + escHtml(post.title) + '</div>' +
      '<div class="neural-tooltip-body">' + escHtml(post.body) + '</div>' +
      '<div class="neural-tooltip-meta">' +
      '<span><i class="fa fa-heart-o"></i> ' + post.likes_count + '</span>' +
      '<span><i class="fa fa-comment-o"></i> ' + post.comments_count + '</span>' +
      tagsHtml +
      '</div></div></div>';
  }

  function escHtml(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function rebuildCanvas(freshPosts) {
    cancelAnimationFrame(raf);

    canvas.style.transition = 'opacity 0.4s';
    canvas.style.opacity = '0';

    setTimeout(function () {
      var existingSvg = canvas.querySelector('.neural-svg');
      canvas.innerHTML = '';
      canvas.appendChild(existingSvg);
      existingSvg.innerHTML = '';

      freshPosts.forEach(function (post) {
        var tmp = document.createElement('div');
        tmp.innerHTML = buildNodeHtml(post);
        canvas.appendChild(tmp.firstChild);
      });

      nodes = Array.from(canvas.querySelectorAll('.neural-node'));
      positions = [];
      lines = [];

      nodes.forEach(function (node, i) {
        var sizeKey = SIZES[i % SIZES.length];
        node.setAttribute('data-size', sizeKey);
        node.style.setProperty('--node-size', NODE_SIZES[sizeKey] + 'px');
      });

      attachHoverHighlight();

      layout();
      raf = requestAnimationFrame(animate);

      canvas.style.opacity = '1';
    }, 420);
  }

  function attachHoverHighlight() {
    nodes.forEach(function (node, i) {
      node.addEventListener('mouseenter', function () {
        lines.forEach(function (l) {
          if (l.i === i || l.j === i) {
            l.el.style.stroke = '#402E2A';
            l.el.style.opacity = '0.7';
            l.el.style.strokeWidth = '2';
          }
        });
      });
      node.addEventListener('mouseleave', function () {
        lines.forEach(function (l) {
          if (l.i === i || l.j === i) {
            l.el.style.stroke = '';
            l.el.style.opacity = '';
            l.el.style.strokeWidth = '';
          }
        });
      });
    });
  }

  function pollUrl() {
    var sp = new URLSearchParams(window.location.search);
    sp.set('format', 'json');
    return window.location.pathname + '?' + sp.toString();
  }

  setInterval(function () {
    fetch(pollUrl(), { headers: { Accept: 'application/json' } })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        var freshIds = data.posts.map(function (p) { return String(p.id); }).join(',');
        if (freshIds !== currentPostIds()) {
          rebuildCanvas(data.posts);
        }
      })
      .catch(function () {});
  }, 15000);

  attachHoverHighlight();

  function randBetween(min, max) {
    return min + Math.random() * (max - min);
  }
});
