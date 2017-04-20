"use strict";

exports.interval = function (n) {
  return function(sub) {
    setInterval(function() {
      sub(new Date().getTime());
    }, n);
  };
};

exports.withTime = function (e) {
  return function(sub) {
    e(function(a) {
      var time = new Date().getTime();
      sub({ time: time, value: a });
    });
  };
};
