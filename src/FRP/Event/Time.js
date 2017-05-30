"use strict";

exports.interval = function (n) {
  return function(sub) {
    setInterval(function() {
      sub(new Date().getTime());
    }, n);
  };
};

exports.animationFrame = function(sub) {
  var loop = function() {
    window.requestAnimationFrame(function() {
      sub();
      loop();
    });
  };
  loop();
};

exports.withTime = function (e) {
  return function(sub) {
    e(function(a) {
      var time = new Date().getTime();
      sub({ time: time, value: a });
    });
  };
};
