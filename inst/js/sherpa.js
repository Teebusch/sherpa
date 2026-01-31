class Sherpa {
  constructor() {
    /** @type {boolean} Circuit breaker to prevent R <-> JS infinite loops */
    this.isIgnoringUpdates = false;

    // msg type: { storeId: string, data: any }
    Shiny.addCustomMessageHandler('sherpa-store-init', (msg) => {
      this.createStore(msg.storeId, msg.data);        
    });
    
    // msg type: { storeId: string, data: any }
    Shiny.addCustomMessageHandler('sherpa-store-update', (msg) => {
      this.updateStore(msg.storeId, msg.data);
    });
    
    // msg type: { html: string }
    Shiny.addCustomMessageHandler('sherpa-hmr', (msg) => {
      this.onHMR(msg.html)
    });
  }

  /**
   * Creates an Alpine store and sets up reactive effects for bi-sync.
   */
  createStore(storeId, data) {
    Alpine.store(storeId, data);
    const store = Alpine.store(storeId);

    // Register effects for each key we want to sync to R
    Object.keys(data).forEach(key => {
      // Alpine.effect automatically tracks dependencies.
      // Whenever store[key] changes, this block re-runs.
      Alpine.effect(() => {
        const value = store[key];
        this.updateR(storeId, key, value);
      });
    });
  }

  /**
   * Updates an Alpine store with data from the server.
   */
  updateStore(storeId, data) {
    const store = Alpine.store(storeId);

    if (typeof store === 'undefined') {
        throw new Error("Store does not exist. Did you forget to call `use_alpine(<storeName>)` in the R UI?")
    }

    this.isIgnoringUpdates = true;
    Object.assign(store, data);

    // Release the lock after Alpine's reactive cycle (next tick)
    // We use a Promise/microtask to ensure the effects triggered 
    // by Object.assign have finished before we turn the lock off.
    Promise.resolve().then(() => {
      this.isIgnoringUpdates = false;
    });
  }

  /**
   * Update from R to Shiny
   * Only send to Shiny if we aren't currently receiving an update from R
   */
  updateR(storeId, key, value) {
    if (!this.isIgnoringUpdates) {
      const msgId = `sherpa_update_${storeId}`;
      const payload = { key: key, value: value };
      Shiny.setInputValue(msgId, payload, { priority: 'event' });
    }
  }
  
  /**
   * Hot Module Reloading for Sherpa dev mode
   * only swaps the INNER body to keep <head> scripts alive
   * Alpine's MutationObserver usually handles the discovery of new components
   * to force a re-scan of a specific element use Alpine.initTree(document.querySelector('#new-element'));
   */
  onHMR(newHTML) {
    const parser = new DOMParser();
      const doc = parser.parseFromString(newHTML, 'text/html');
      const newBodyContent = doc.querySelector('body').innerHTML;
      console.log(newHTML, newBodyContent)
      document.body.innerHTML = newBodyContent;
      window.dispatchEvent(new CustomEvent('sherpa:hmr-complete'));
  }
}


document.addEventListener('alpine:init', () => {
    console.log("Alpine initialized")
});


/**
 * Instantiate and initialize Sherpa when Shiny is ready.
 */
$(document).on('shiny:connected', function() {
  console.log("Shiny connected")
  window.sherpa = new Sherpa();
});
