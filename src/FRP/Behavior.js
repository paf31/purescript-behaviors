"use strict";

exports.pureImpl = function (a) {
  return function() {
    return function() {
      return a;
    };
  };
};

exports.mapImpl = function (f) {
  return function(b) {
    return function() {
      var live = b();

      return function() {
        return f(live());
      };
    };
  };
};

exports.zip = function (f) {
  return function (b1) {
    return function (b2) {
      return function() {
        var l1 = b1();
        var l2 = b2();

        return function() {
          return f(l1())(l2());
        };
      };
    };
  };
};

exports.step = function (a) {
  return function (e) {
    return function() {
      var latest = a;

      e(function(value) {
        latest = value;
      });

      return function() {
        return latest;
      };
    };
  };
};

exports.sample = function (f) {
  return function(b) {
    return function(e) {
      return function(sub) {
        var live = b();

        e(function(value) {

          sub(f(live())(value));
        });
      };
    };
  };
};
