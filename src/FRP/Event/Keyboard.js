"use strict";

var currentKeys = [];
addEventListener("keydown", function(e) {
  var index = currentKeys.indexOf(e.keyCode);
  if (index < 0) {
    currentKeys.push(e.keyCode);
  }
});
addEventListener("keyup", function(e) {
  var index = currentKeys.indexOf(e.keyCode);
  if (index >= 0) {
    currentKeys.splice(index, 1);
  }
});

exports.withKeys = function (e) {
  return function(sub) {
    return e(function(a) {
      sub({ keys: currentKeys, value: a });
    });
  };
};

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
