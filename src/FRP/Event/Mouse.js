"use strict";

var currentPosition;
addEventListener("mousemove", function(e) {
  currentPosition = { x: e.clientX, y: e.clientY };
});

var currentButtons = [];
addEventListener("mousedown", function(e) {
  currentButtons.push(e.button);
});
addEventListener("mouseup", function(e) {
  var index = currentButtons.indexOf(e.button);
  if (index >= 0) {
    currentButtons.splice(index, 1);
  }
});

exports.withPosition = function (e) {
  return function(sub) {
    return e(function(a) {
      sub({ pos: currentPosition, value: a });
    });
  };
};

exports.withButtons = function (e) {
  return function(sub) {
    return e(function(a) {
      sub({ buttons: currentButtons, value: a });
    });
  };
};

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
