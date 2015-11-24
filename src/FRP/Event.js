// module FRP.Event

var Behavior = require('behavior')

exports.pureImpl = function (a) {
  return Behavior.Event.pure(a);
}

exports.mapImpl = function (f) {
  return function(e) {
    return Behavior.Event.map(e, f);
  };
}

exports.zip = function (f) {
  return function (e1) {
    return function (e2) {
      return Behavior.Event.zip(e1, e2, function(a, b) {
        return f(a)(b);
      });
    };
  };
}

exports.mergeImpl = function (e1) {
  return function(e2) {
    return Behavior.Event.merge(e1, e2);
  };
}

exports.fold = function (f) {
  return function(e) {
    return function(b) {
      return Behavior.Event.fold(e, b, function(a, b) {
        return f(a)(b);
      });
    };
  };
}

exports.filter = function (p) {
  return function(e) {
    return Behavior.Event.filter(e, p);
  };
}

exports.subscribe = function (f) {
  return function(e) {
    return function() {
      e.subscribe(function(a) {
        f(a)();
      });
    };
  };
};
