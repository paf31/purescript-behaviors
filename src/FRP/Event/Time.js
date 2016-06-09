"use strict";

var Event = require('FRP/Event').Event;

exports.interval = function (n) {
  return Event.interval(n);
};
