/* ── Neural feed — noduri floating cu conexiuni SVG ─────── */
document.addEventListener('DOMContentLoaded', function () {
  var canvas = document.getElementById('neuralCanvas');
  var svg    = document.getElementById('neuralSvg');
  if (!canvas || !svg) return;

  var nodes = Array.from(canvas.querySelectorAll('.neural-node'));
  if (!nodes.length) return;

  var W, H;
  var positions  = []; // { x, y, vx, vy, size }
  var lines      = [];
  var raf;
  var MAX_DIST   = 260; // distanța maximă pentru conexiune
  var SIZES      = ['sm', 'md', 'md', 'lg', 'md', 'sm']; // ciclu
  var NODE_SIZES = { sm: 46, md: 58, lg: 70 };
  var PADDING    = 80;

  /* ── 1. Setare dimensiuni noduri ─────────────────────── */
  nodes.forEach(function (node, i) {
    var sizeKey = SIZES[i % SIZES.length];
    node.setAttribute('data-size', sizeKey);
    node.style.setProperty('--node-size', NODE_SIZES[sizeKey] + 'px');
  });

  /* ── 2. Calculare layout inițial ─────────────────────── */
  function layout() {
    W = canvas.offsetWidth;

    /* Distribuie nodurile în grid cu offset aleator */
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

      /* clampare */
      x = Math.max(r + 4, Math.min(W - r - 4, x));
      y = Math.max(r + 4, Math.min(H - r - 4, y));

      positions[i] = {
        x:  x,
        y:  y,
        ox: x, // origine — centrul zonei de floating
        oy: y,
        vx: randBetween(-0.08, 0.08),
        vy: randBetween(-0.08, 0.08),
        r:  r
      };

      applyPos(node, positions[i]);

      /* tooltip sus/jos în funcție de poziție */
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

  /* ── 3. Construiesc liniile SVG ──────────────────────── */
  function buildLines() {
    svg.innerHTML = '';
    lines = [];

    /* Fiecare nod se conectează cu 2-3 vecini mai apropiați */
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
        /* evită duplicate */
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

  /* ── 4. Animație floating ────────────────────────────── */
  function animate() {
    nodes.forEach(function (node, i) {
      var p = positions[i];
      p.x += p.vx;
      p.y += p.vy;

      /* Forță de atracție spre origine (spring) */
      var ORBIT = 40; // raza maximă față de origine
      var dx0 = p.x - p.ox;
      var dy0 = p.y - p.oy;
      var dist0 = Math.sqrt(dx0 * dx0 + dy0 * dy0);
      if (dist0 > ORBIT) {
        var pull = (dist0 - ORBIT) * 0.012;
        p.vx -= (dx0 / dist0) * pull;
        p.vy -= (dy0 / dist0) * pull;
      }

      /* Drift ușor aleator */
      p.vx += randBetween(-0.001, 0.001);
      p.vy += randBetween(-0.001, 0.001);

      /* Limitare viteză */
      var speed = Math.sqrt(p.vx * p.vx + p.vy * p.vy);
      if (speed > 0.05) { p.vx *= 0.05 / speed; p.vy *= 0.05 / speed; }
      if (speed < 0.003) { p.vx += randBetween(-0.003, 0.003); p.vy += randBetween(-0.003, 0.003); }

      applyPos(node, p);

      /* Tooltip sus/jos */
      if (p.y < 120) {
        node.classList.add('tooltip-below');
      } else {
        node.classList.remove('tooltip-below');
      }
    });

    updateLines();
    raf = requestAnimationFrame(animate);
  }

  /* ── 5. Click pe nod → panel (preluat de delegarea din feed.js) ── */
  /* Nodurile au clasa .neural-node și data-post-id, feed.js le prinde automat */

  /* ── 6. Highlight conexiuni la hover ─────────────────── */
  nodes.forEach(function (node, i) {
    node.addEventListener('mouseenter', function () {
      lines.forEach(function (l) {
        if (l.i === i || l.j === i) {
          l.el.style.stroke  = '#402E2A';
          l.el.style.opacity = '0.7';
          l.el.style.strokeWidth = '2';
        }
      });
    });
    node.addEventListener('mouseleave', function () {
      lines.forEach(function (l) {
        if (l.i === i || l.j === i) {
          l.el.style.stroke  = '';
          l.el.style.opacity = '';
          l.el.style.strokeWidth = '';
        }
      });
    });
  });

  /* ── 7. Resize ───────────────────────────────────────── */
  var resizeTimer;
  window.addEventListener('resize', function () {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function () {
      cancelAnimationFrame(raf);
      layout();
      raf = requestAnimationFrame(animate);
    }, 200);
  });

  /* ── Start ───────────────────────────────────────────── */
  layout();
  raf = requestAnimationFrame(animate);

  /* ── Util ────────────────────────────────────────────── */
  function randBetween(min, max) {
    return min + Math.random() * (max - min);
  }
});
