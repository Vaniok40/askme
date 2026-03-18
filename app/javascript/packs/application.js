// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

/*= require jquery3*/

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")
require("../feed")
require("jquery")

import 'bootstrap/dist/js/bootstrap'

$(function(){
    $('#ask-button').click(function(){
        $('#ask-form').slideToggle(300);
        return false;
    });
});

$(function(){
    var canvas = document.getElementById("myCanvas");
    var ctx = canvas.getContext("2d");
    var ballRadius = 10;
    var x = canvas.width / 2;
    var y = canvas.height - 30;
    var dx = 2;
    var dy = -2;

    function drawBall() {
        ctx.beginPath();
        ctx.arc(x, y, ballRadius, 0, Math.PI * 2);
        ctx.fillStyle = "#0095DD";
        ctx.fill();
        ctx.closePath();
    }

    function draw() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        drawBall();

        if (x + dx > canvas.width - ballRadius || x + dx < ballRadius) {
            dx = -dx;
        }
        if (y + dy > canvas.height - ballRadius || y + dy < ballRadius) {
            dy = -dy;
        }

        x += dx;
        y += dy;
    }

    setInterval(draw, 10);

});

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//

// const imagePath = (name) => images(name, true)
