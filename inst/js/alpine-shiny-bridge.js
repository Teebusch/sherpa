document.addEventListener('alpine:init', () => {
    
    window.AlpineShiny = {
        stores: new Set()
    };

    // msg type: { storeId: "string", data: any, initial: boolean }
    Shiny.addCustomMessageHandler('alpine-store-sync', (msg) => {
        
        const storeId = msg.storeId;
        const payload = msg.data;
        
        try {
             if (msg.initial) {
                 Alpine.store(storeId, payload);
                 window.AlpineShiny.stores.add(storeId);
             } else {
                 const currentStore = Alpine.store(storeId);
                 
                 if (typeof currentStore === 'undefined') {
                     // Fallback: if update precedes init
                     Alpine.store(storeId, payload);
                 } else {
                     Object.keys(payload).forEach(key => {
                         currentStore[key] = payload[key];
                     });
                 }
             }
        } catch (e) {
            console.error(`[ShinyAlpine] Error syncing store '${storeId}':`, e);
        }
    });
    
});