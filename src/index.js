export const initMaestroPorts = (app, options) => {
  // Listen to a maestro event
  app.ports.portAddEventListener && app.ports.portAddEventListener.subscribe(function ({ eventName }) {
    options.events.on(eventName, function (payload) {
      app.ports.portEventReceived && app.ports.portEventReceived.send({ eventName, payload });
    });
  });

  // Unlisten to a maestro event
  app.ports.portRemoveEventListener && app.ports.portRemoveEventListener.subscribe(function ({ eventName }) {
    options.events.removeListener(eventName, function () { });
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

  // Notify
  app.ports.portNotify && app.ports.portNotify.subscribe(function (payload) {
    options.services.notify(payload);
  });
};

export const makeComponentConfig = (config) => ({
  closable: (config || {}).closable || false,
  editable: (config || {}).editable || false,
  deletable: (config || {}).deletable || false,
  searchable: (config || {}).searchable || false,
  newable: (config || {}).newable || false,
  notifications: {
    created: ((config || {}).notifications || {}).created || false,
    deleted: ((config || {}).notifications || {}).deleted || false,
    fetched: ((config || {}).notifications || {}).fetched || false,
    updated: ((config || {}).notifications || {}).updated || false,
    notCreated: ((config || {}).notifications || {}).notCreated || false,
    notDeleted: ((config || {}).notifications || {}).notDeleted || false,
    notFetched: ((config || {}).notifications || {}).notFetched || false,
    notUpdated: ((config || {}).notifications || {}).notUpdated || false,
  },
});