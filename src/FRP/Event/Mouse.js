"use strict";

exports.move = function(sub) {
  var cb = function(e) {
    sub({ x: e.clientX, y: e.clientY });
  };
  addEventListener("mousemove", cb);
  return function() {
    removeEventListener("mousemove", cb);
  };
};

exports.down = function(sub) {
  var cb = function(e) {
    sub(e.button);
  };
  addEventListener("mousedown", cb);
  return function() {
    removeEventListener("mousedown", cb);
  };
};

exports.up = function(sub) {
  var cb = function(e) {
    sub(e.button);
  };
  addEventListener("mouseup", cb);
  return function() {
    removeEventListener("mouseup", cb);
  };
};
