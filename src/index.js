export const initMaestroPorts = (app, options) => {
  // Listen to a maestro event
  app.ports.portAddEventListener && app.ports.portAddEventListener.subscribe(function ({ eventName }) {
    options.events.on(eventName, function (payload) {
      app.ports.portEventReceived && app.ports.portEventReceived.send({ eventName, payload });
    });
  });

  // Emit an event to the maestro
  app.ports.portEmitEvent && app.ports.portEmitEvent.subscribe(function ({ eventName, payload }) {
    options.events.emit(eventName, payload);
  });

  // Blocks the maestro navigation
  app.ports.portBlockNavigation && app.ports.portBlockNavigation.subscribe(function (_) {
    options.navigation.blockNavigation();
  });

  // Unblock the maestro navigation
  app.ports.portUnblockNavigation && app.ports.portUnblockNavigation.subscribe(function (_) {
    options.navigation.unblockNavigation();
  });
};

export const makeComponentConfig = (config) => ({
  closable: (config || {}).closable || false,
  editable: (config || {}).editable || false,
  deletable: (config || {}).deletable || false
});