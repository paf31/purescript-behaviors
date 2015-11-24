// module FRP.Event.Time

var Behavior = require('behavior');

exports.interval = function (n) {
  return Behavior.Event.interval(n);
};
