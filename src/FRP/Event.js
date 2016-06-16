"use strict";

exports.pureImpl = function (a) {
  return function(sub) {
    sub(a);
  }
};

exports.mapImpl = function (f) {
  return function(e) {
    return function (sub) {
      e(function(a) {
        sub(f(a));
      });
    }
  };
};

exports.zip = function (f) {
  return function (e1) {
    return function (e2) {
      return function(sub) {
        var a_latest, b_latest;
        var a_fired = false, b_fired = false;

        e1(function(a) {
          a_latest = a;
          a_fired = true;

          if (b_fired) {
            sub(f(a_latest)(b_latest));
          }
        });

        e2(function(b) {
          b_latest = b;
          b_fired = true;

          if (a_fired) {
            sub(f(a_latest)(b_latest));
          }
        });
      };
    };
  };
};

exports.mergeImpl = function (e1) {
  return function(e2) {
    return function(sub) {
      e1(sub);
      e2(sub);
    }
  };
};

exports.fold = function (f) {
  return function(e) {
    return function(b) {
      return function(sub) {
        var result = b;

        e(function(a) {
          sub(result = f(a)(result));
        });
      };
    };
  };
};

exports.filter = function (p) {
  return function(e) {
    return function(sub) {
      e(function(a) {
        if (p(a)) {
          sub(a);
        }
      });
    };
  };
};

exports.subscribe = function (f) {
  return function(e) {
    return function() {
      e(function(a) {
        f(a)();
      });
    };
  };
};
