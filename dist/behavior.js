var Behavior = (function() {

  var b = {};

  /**
   * Event :: forall a. ((a -> void) -> void) -> Event a
   */
  b.Event = function(subscribe) {
  
    this.subscribe = subscribe;
  };
  
  /**
   * Event.pure :: forall a. a -> Event a
   */
  b.Event.pure = function(a) {

    return new b.Event(function(sub) {
      
      sub(a);
    });
  };

  /**
   * Event.map :: forall a b. (Event a, a -> b) -> Event b
   */
  b.Event.map = function(e, f) {

    return new b.Event(function (sub) {
      
      e.subscribe(function(a) {
        
        sub(f(a)); 
      }); 
    });
  };

  /**
   * Event.apply :: forall a b. (Event (a -> b), Event a) -> Event b 
   */
  b.Event.apply = function(e1, e2) {
    
    return new b.Event(function (sub) {
      
      var f_latest, x_latest;
      var f_fired = false, x_fired = false;

      e1.subscribe(function(f) {
        f_latest = f;
        f_fired = true;
        if (x_fired) {
          sub(f_latest(x_latest));
        }
      }); 
      
      e2.subscribe(function(x) {
        x_latest = x;
        x_fired = true;
        if (f_fired) {
          sub(f_latest(x_latest));
        }
      }); 
    });
  };

  /**
   * Event.interval :: Number -> Event Number 
   */
  b.Event.interval = function(n) {

    return new b.Event(function(sub) {

      setInterval(function() {
        
        sub(new Date().getTime());
      }, n);
    });
  };

  /**
   * Event.fold :: forall a b. (Event a, b, (a, b) -> b) -> Event b
   */
  b.Event.fold = function(e, init, f) {
  
    return new b.Event(function(sub) {

      var result = init;

      e.subscribe(function(a) {
       
        sub(result = f(a, result)); 
      });
    });
  };

  /**
   * Live :: forall a. (-> a) -> Live a
   */
  b.Live = function(get) {

    this.get = get;
  };

  /**
   * Behavior :: forall a. (-> Live a) -> Behavior a
   */
  b.Behavior = function(subscribe) {

    this.subscribe = subscribe;
  };

  /**
   * Behavior.pure :: forall a. a -> Behavior a
   */
  b.Behavior.pure = function(a) {

    return new b.Behavior(function() {
     
      return new b.Live(function() {
        
        return a;
      }); 
    });
  };

  /**
   * Behavior.map :: forall a b. (Behavior a, a -> b) -> Behavior b
   */
  b.Behavior.map = function(b1, f) {

    return new b.Behavior(function() {
      
      var live = b1.subscribe();
      
      return new b.Live(function() {
        
        return f(live.get());
      }); 
    });
  };

  /**
   * Behavior.apply :: forall a b. (Behavior (a -> b), Behavior a) -> Behavior b
   */
  b.Behavior.apply = function (b1, b2) {
    
    return new b.Behavior(function() {
     
      var l1 = b1.subscribe();
      var l2 = b2.subscribe();

      return new b.Live(function() {
        
        return l1.get()(l2.get());
      });
    });
  };

  /**
   * Behavior.step :: forall a. (a, Event a) -> Behavior a
   */
  b.Behavior.step = function(a, e) {
 
    return new b.Behavior(function() {

      var latest = a;

      e.subscribe(function(value) {
       
        latest = value;
      });

      return new b.Live(function() {

        return latest;
      });
    });
  };

  /**
   * Behavior.sample :: forall a b c. (Behavior a, Event b, (a, b) -> c) -> Event c
   */
  b.Behavior.sample = function(b1, e, f) {
    
    return new b.Event(function(sub) {
     
      var live = b1.subscribe(); 

      e.subscribe(function(value) {

        sub(f(live.get(), value));
      });
    });
  };

  return b;
})();
