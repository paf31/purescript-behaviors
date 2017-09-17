"use strict";

var currentKeys = {};
addEventListener("keydown", function(e) {
  currentKeys[e.keyCode] = true;
});
addEventListener("keyup", function(e) {
  currentKeys[e.keyCode] = false;
});

exports.withKeys = function (e) {
  return function(sub) {
    return e(function(a) {
      var currentKeysArray = Object.keys(currentKeys)
            .filter(function(k) { return currentKeys[k] });
      sub({ keys: currentKeysArray, value: a });
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
