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

const valueOrDefault = (value, defaultValue) => typeof value === 'undefined' ? defaultValue : value;

export const makeComponentConfig = (config) => ({
  closable: valueOrDefault((config || {}).closable, false),
  closeTitle: valueOrDefault((config || {}).closeTitle, null),
  customEvents: valueOrDefault((config || {}).customEvents, []),
  editable: valueOrDefault((config || {}).editable, false),
  deletable: valueOrDefault((config || {}).deletable, false),
  loadingButtonLabel: valueOrDefault((config || {}).loadingButtonLabel, null),
  searchable: valueOrDefault((config || {}).searchable, false),
  newable: valueOrDefault((config || {}).newable, false),
  notifications: {
    created: valueOrDefault(((config || {}).notifications || {}).created, false),
    deleted: valueOrDefault(((config || {}).notifications || {}).deleted, false),
    fetched: valueOrDefault(((config || {}).notifications || {}).fetched, false),
    updated: valueOrDefault(((config || {}).notifications || {}).updated, false),
    notCreated: valueOrDefault(((config || {}).notifications || {}).notCreated, false),
    notDeleted: valueOrDefault(((config || {}).notifications || {}).notDeleted, false),
    notFetched: valueOrDefault(((config || {}).notifications || {}).notFetched, false),
    notUpdated: valueOrDefault(((config || {}).notifications || {}).notUpdated, false),
  },
  showSubmitLoader: valueOrDefault((config || {}).showSubmitLoader, false),
  showReset: valueOrDefault((config || {}).showReset, false),
  submitLabel: valueOrDefault((config || {}).submitLabel, null),
  title: valueOrDefault((config || {}).title, null),
});

export const withMasterDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    fetched: valueOrDefault(((config || {}).notifications || {}).fetched, false),
    notFetched: valueOrDefault(((config || {}).notifications || {}).notFetched, true),
  },
});

export const withNewDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    created: valueOrDefault(((config || {}).notifications || {}).created, true),
    notCreated: valueOrDefault(((config || {}).notifications || {}).notCreated, true),
  },
});

export const withDeleteDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    deleted: valueOrDefault(((config || {}).notifications || {}).deleted, true),
    notDeleted: valueOrDefault(((config || {}).notifications || {}).notDeleted, true),
  },
});

export const withDetailDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    fetched: valueOrDefault(((config || {}).notifications || {}).fetched, false),
    notFetched: valueOrDefault(((config || {}).notifications || {}).notFetched, true),
  },
});

export const withEditDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    fetched: valueOrDefault(((config || {}).notifications || {}).fetched, false),
    updated: valueOrDefault(((config || {}).notifications || {}).updated, true),
    notFetched: valueOrDefault(((config || {}).notifications || {}).notFetched, true),
    notUpdated: valueOrDefault(((config || {}).notifications || {}).notUpdated, true),
  },
});