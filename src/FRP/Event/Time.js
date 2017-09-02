"use strict";

exports.interval = function (n) {
  return function(sub) {
    var interval = setInterval(function() {
      sub(new Date().getTime());
    }, n);
    return function() {
      clearInterval(interval);
    };
  };
};

exports.animationFrame = function(sub) {
  var cancelled = false;
  var loop = function() {
    window.requestAnimationFrame(function() {
      sub();
      if (!cancelled) {
        loop();
      }
    });
  };
  loop();
  return function() {
    cancelled = true;
  }
};

exports.withTime = function (e) {
  return function(sub) {
    return e(function(a) {
      var time = new Date().getTime();
      sub({ time: time, value: a });
    });
  };
};
