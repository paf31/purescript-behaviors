// module FRP.Behavior

var Event = require('FRP/Event').Event;

/**
 * Live :: forall a. (-> a) -> Live a
 */
var Live = function(get) {

  this.get = get;
};

exports.Live = Live;

/**
 * Behavior :: forall a. (-> Live a) -> Behavior a
 */
var Behavior = function(subscribe) {

  this.subscribe = subscribe;
};

/**
 * Behavior.pure :: forall a. a -> Behavior a
 */
Behavior.pure = function(a) {

  return new Behavior(function() {
   
    return new Live(function() {
      
      return a;
    }); 
  });
};

/**
 * Behavior.map :: forall a b. (Behavior a, a -> b) -> Behavior b
 */
Behavior.map = function(b1, f) {

  return new Behavior(function() {
    
    var live = b1.subscribe();
    
    return new Live(function() {
      
      return f(live.get());
    }); 
  });
};

/**
 * Behavior.zip :: forall a b c. (Behavior a, Behavior b, (a, b) -> c) -> Behavior c
 */
Behavior.zip = function (b1, b2, f) {
  
  return new Behavior(function() {
   
    var l1 = b1.subscribe();
    var l2 = b2.subscribe();

    return new Live(function() {
      
      return f(l1.get(), l2.get());
    });
  });
};

/**
 * Behavior.step :: forall a. (a, Event a) -> Behavior a
 */
Behavior.step = function(a, e) {

  return new Behavior(function() {

    var latest = a;

    e.subscribe(function(value) {
     
      latest = value;
    });

    return new Live(function() {

      return latest;
    });
  });
};

/**
 * Behavior.sample :: forall a b c. (Behavior a, Event b, (a, b) -> c) -> Event c
 */
Behavior.sample = function(b1, e, f) {
  
  return new Event(function(sub) {
   
    var live = b1.subscribe(); 

    e.subscribe(function(value) {

      sub(f(live.get(), value));
    });
  });
};

exports.Behavior = Behavior;


exports.pureImpl = function (a) {
  return Behavior.pure(a);
}

exports.mapImpl = function (f) {
  return function(e) {
    return Behavior.map(e, f);
  };
}

exports.zip = function (f) {
  return function (b1) {
    return function (b2) {
      return Behavior.zip(b1, b2, function(a, b) {
        return f(a)(b);  
      });
    };
  };
}

exports.step = function (a) {
  return function (e) {
    return Behavior.step(a, e);
  };
}

exports.sample = function (f) {
  return function(b) {
    return function(e) {
      return Behavior.sample(b, e, function(a, b) {
        return f(a)(b);
      });
    };
  };
}
