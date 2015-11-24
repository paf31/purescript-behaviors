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
   * Event.zip :: forall a b c. (Event a, Event b, (a, b) -> c) -> Event c
   */
  b.Event.zip = function(e1, e2, f) {
    
    return new b.Event(function(sub) {
     
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
   * Event.filter :: forall a. (Event a, a -> Boolean) -> Event a
   */
  b.Event.filter = function(e, p) {

    return new b.Event(function(sub) {

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
  b.Event.merge = function(e1, e2) {

    return new b.Event(function(sub) {
     
      e1.subscribe(sub);
      e2.subscribe(sub); 
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
   * Behavior.zip :: forall a b c. (Behavior a, Behavior b, (a, b) -> c) -> Behavior c
   */
  b.Behavior.zip = function (b1, b2, f) {
    
    return new b.Behavior(function() {
     
      var l1 = b1.subscribe();
      var l2 = b2.subscribe();

      return new b.Live(function() {
        
        return f(l1.get(), l2.get());
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

module.exports = Behavior;
