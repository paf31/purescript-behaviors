"use strict";

exports.down = function(sub) {
  addEventListener("keydown", function(e) {
    sub(e.keyCode);
  });
};

exports.up = function(sub) {
  addEventListener("keyup", function(e) {
    sub(e.keyCode);
  });
};
