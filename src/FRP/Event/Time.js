"use strict";

exports.interval = function (n) {
  return function(sub) {
    setInterval(function() {
      sub(new Date().getTime());
    }, n);
  };
};
