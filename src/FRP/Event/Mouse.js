"use strict";

exports.move = function(sub) {
  addEventListener("mousemove", function(e) {
    sub({ x: e.clientX, y: e.clientY });
  });
};

exports.down = function(sub) {
  addEventListener("mousedown", function(e) {
    sub(e.button);
  });
};

exports.up = function(sub) {
  addEventListener("mouseup", function(e) {
    sub(e.button);
  });
};
