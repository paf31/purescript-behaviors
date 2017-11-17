"use strict";

exports.pureImpl = function (a) {
  return function(sub) {
    sub(a);
    return function() {};
  }
};

exports.mapImpl = function (f) {
  return function(e) {
    return function (sub) {
      return e(function(a) {
        sub(f(a));
      });
    }
  };
};

exports.never = function (sub) {
  return function() {};
};

exports.applyImpl = function (e1) {
  return function (e2) {
    return function(sub) {
      var a_latest, b_latest;
      var a_fired = false, b_fired = false;

      var cancel1 = e1(function(a) {
        a_latest = a;
        a_fired = true;

        if (b_fired) {
          sub(a_latest(b_latest));
        }
      });

      var cancel2 = e2(function(b) {
        b_latest = b;
        b_fired = true;

        if (a_fired) {
          sub(a_latest(b_latest));
        }
      });

      return function() {
        cancel1();
        cancel2();
      };
    };
  };
};

exports.mergeImpl = function (e1) {
  return function(e2) {
    return function(sub) {
      var cancel1 = e1(sub);
      var cancel2 = e2(sub);

      return function() {
        cancel1();
        cancel2();
      };
    }
  };
};

exports.fold = function (f) {
  return function(e) {
    return function(b) {
      return function(sub) {
        var result = b;

        return e(function(a) {
          sub(result = f(a)(result));
        });
      };
    };
  };
};

exports.filter = function (p) {
  return function(e) {
    return function(sub) {
      return e(function(a) {
        if (p(a)) {
          sub(a);
        }
      });
    };
  };
};

exports.sampleOn = function (e1) {
  return function (e2) {
    return function(sub) {
      var latest;
      var fired = false;

      var cancel1 = e1(function(a) {
        latest = a;
        fired = true;
      });

      var cancel2 = e2(function(f) {
        if (fired) {
          sub(f(latest));
        }
      });

      return function() {
        cancel1();
        cancel2();
      };
    };
  };
};

exports.subscribe = function (e) {
  return function(f) {
    return function() {
      return e(function(a) {
        f(a)();
      });
    };
  };
};

exports.keepLatest = function (e) {
  return function(sub) {
    var cancelInner;

    var cancelOuter = e(function(inner) {
      cancelInner && cancelInner();
      cancelInner = inner(sub);
    });

    return function() {
      cancelInner && cancelInner();
      cancelOuter();
    }
  };
};

exports.create = function () {
  var subs = [];
  return {
    event: function(sub) {
      subs.push(sub);
      return function() {
        var index = subs.indexOf(sub);
        if (index >= 0) {
          subs.splice(index, 1);
        }
      };
    },
    push: function(a) {
      return function() {
        for (var i = 0; i < subs.length; i++) {
          subs[i](a);
        }
      };
    }
  };
};

exports.fix = function(f) {
  var s = exports.create();
  var io = f(s.event);

  return function(sub) {
    var sub1 = function(a) {
      s.push(a)();
    };
    var cancel1 = io.input(sub1);
    var cancel2 = io.output(sub);

    return function() {
      cancel1();
      cancel2();
    };
  };
};
