// module FRP.Event.Time

var Event = require('FRP/Event').Event;

exports.interval = function (n) {
  return Event.interval(n);
};
