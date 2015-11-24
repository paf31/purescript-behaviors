// module FRP.Behavior

var Behavior = require('behavior');

exports.pureImpl = function (a) {
  return Behavior.Behavior.pure(a);
}

exports.mapImpl = function (f) {
  return function(e) {
    return Behavior.Behavior.map(e, f);
  };
}

exports.zip = function (f) {
  return function (b1) {
    return function (b2) {
      return Behavior.Behavior.zip(b1, b2, function(a, b) {
        return f(a)(b);  
      });
    };
  };
}

exports.step = function (a) {
  return function (e) {
    return Behavior.Behavior.step(a, e);
  };
}

exports.sample = function (f) {
  return function(b) {
    return function(e) {
      return Behavior.Behavior.sample(b, e, function(a, b) {
        return f(a)(b);
      });
    };
  };
}
