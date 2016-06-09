"use strict";

/**
 * Event :: forall a. ((a -> void) -> void) -> Event a
 */
var Event = function(subscribe) {

  this.subscribe = subscribe;
};

/**
 * Event.pure :: forall a. a -> Event a
 */
Event.pure = function(a) {

  return new Event(function(sub) {

    sub(a);
  });
};

/**
 * Event.map :: forall a b. (Event a, a -> b) -> Event b
 */
Event.map = function(e, f) {

  return new Event(function (sub) {

    e.subscribe(function(a) {

      sub(f(a));
    });
  });
};

/**
 * Event.zip :: forall a b c. (Event a, Event b, (a, b) -> c) -> Event c
 */
Event.zip = function(e1, e2, f) {

  return new Event(function(sub) {

    var a_latest, b_latest;
    var a_fired = false, b_fired = false;

    e1.subscribe(function(a) {

      a_latest = a;
      a_fired = true;

      if (b_fired) {

        sub(f(a_latest, b_latest));
      }
    });

    e2.subscribe(function(b) {

      b_latest = b;
      b_fired = true;

      if (a_fired) {

        sub(f(a_latest, b_latest));
      }
    });
  });
};

/**
 * Event.interval :: Number -> Event Number
 **/
Event.interval = function(n) {

  return new Event(function(sub) {

    setInterval(function() {

      sub(new Date().getTime());
    }, n);
  });
};


/**
 * Event.fold :: forall a b. (Event a, b, (a, b) -> b) -> Event b
 */
Event.fold = function(e, init, f) {

  return new Event(function(sub) {

    var result = init;

    e.subscribe(function(a) {

      sub(result = f(a, result));
    });
  });
};

/**
 * Event.filter :: forall a. (Event a, a -> Boolean) -> Event a
 */
Event.filter = function(e, p) {

  return new Event(function(sub) {

    e.subscribe(function(a) {

      if (p(a)) {

        sub(a);
      }
    });
  });
};

/**
 * Event.merge :: forall a. (Event a, Event a) -> Event a
 */
Event.merge = function(e1, e2) {

  return new Event(function(sub) {

    e1.subscribe(sub);
    e2.subscribe(sub);
  });
};

module.exports.Event = Event;

exports.pureImpl = function (a) {
  return Event.pure(a);
}

exports.mapImpl = function (f) {
  return function(e) {
    return Event.map(e, f);
  };
}

exports.zip = function (f) {
  return function (e1) {
    return function (e2) {
      return Event.zip(e1, e2, function(a, b) {
        return f(a)(b);
      });
    };
  };
}

exports.mergeImpl = function (e1) {
  return function(e2) {
    return Event.merge(e1, e2);
  };
}

exports.fold = function (f) {
  return function(e) {
    return function(b) {
      return Event.fold(e, b, function(a, b) {
        return f(a)(b);
      });
    };
  };
}

exports.filter = function (p) {
  return function(e) {
    return Event.filter(e, p);
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
