"use strict";

exports.down = function(sub) {
  var cb = function(e) {
    sub(e.keyCode);
  };
  addEventListener("keydown", cb);
  return function() {
    removeEventListener("keydown", cb);
  }
};

exports.up = function(sub) {
  var cb = function(e) {
    sub(e.keyCode);
  };
  addEventListener("keyup", cb);
  return function() {
    removeEventListener("keyup", cb);
  }
};
