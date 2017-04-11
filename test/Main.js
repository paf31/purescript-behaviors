"use strict";

exports.display = function (s) {
  return function() {
    document.body.innerText = s;
  };
};
