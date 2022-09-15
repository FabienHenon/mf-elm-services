export const initMaestroPorts = (app, options) => {
  const events = {
    on:
      options.events.on ||
      function () {
        console.log("Unset on event function");
      },
    once:
      options.events.once ||
      function () {
        console.log("Unset once event function");
      },
    removeListener:
      options.events.removeListener ||
      function () {
        console.log("Unset removeListener event function");
      },
    emit:
      options.events.emit ||
      function () {
        console.log("Unset emit event function");
      },
  };
  // Listen to a maestro event
  app.ports.portAddEventListener &&
    app.ports.portAddEventListener.subscribe(function ({ eventName }) {
      events.on(eventName, function (payload) {
        app.ports.portEventReceived &&
          app.ports.portEventReceived.send({ eventName, payload });
      });
    });

  // Listen to a maestro event once
  app.ports.portAddEventListenerOnce &&
    app.ports.portAddEventListenerOnce.subscribe(function ({ eventName }) {
      events.once(eventName, function (payload) {
        app.ports.portEventReceived &&
          app.ports.portEventReceived.send({ eventName, payload });
      });
    });

  // Unlisten to a maestro event
  app.ports.portRemoveEventListener &&
    app.ports.portRemoveEventListener.subscribe(function ({ eventName }) {
      events.removeListener(eventName, function () {});
    });

  // Emit an event to the maestro
  app.ports.portEmitEvent &&
    app.ports.portEmitEvent.subscribe(function ({ eventName, payload, ref }) {
      events.emit(eventName, payload);

      if (typeof ref !== "undefined") {
        app.ports.portEmitAfterEvent &&
          app.ports.portEmitAfterEvent.send({ ref: ref });
      }
    });

  // Blocks the maestro navigation
  app.ports.portBlockNavigation &&
    app.ports.portBlockNavigation.subscribe(function (_) {
      options.navigation.blockNavigation();
    });

  // Unblock the maestro navigation
  app.ports.portUnblockNavigation &&
    app.ports.portUnblockNavigation.subscribe(function (_) {
      options.navigation.unblockNavigation();
    });

  // Notify
  app.ports.portNotify &&
    app.ports.portNotify.subscribe(function (payload) {
      options.services.notify(payload);
    });

  // Get localstorage item
  app.ports.portGetLocalStorageItem &&
    app.ports.portGetLocalStorageItem.subscribe(function ({ key, ref }) {
      const value = JSON.parse(localStorage.getItem(key));

      if (typeof ref !== "undefined") {
        app.ports.portLocalStorageAfterEvent &&
          app.ports.portLocalStorageAfterEvent.send({ ref: ref, value: value });
      }
    });

  // Set localstorage item
  app.ports.portSetLocalStorageItem &&
    app.ports.portSetLocalStorageItem.subscribe(function ({ key, value }) {
      localStorage.setItem(key, JSON.stringify(value));
    });
};

const valueOrDefault = (value, defaultValue) =>
  typeof value === "undefined" ? defaultValue : value;

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
    created: valueOrDefault(
      ((config || {}).notifications || {}).created,
      false
    ),
    deleted: valueOrDefault(
      ((config || {}).notifications || {}).deleted,
      false
    ),
    fetched: valueOrDefault(
      ((config || {}).notifications || {}).fetched,
      false
    ),
    updated: valueOrDefault(
      ((config || {}).notifications || {}).updated,
      false
    ),
    notCreated: valueOrDefault(
      ((config || {}).notifications || {}).notCreated,
      false
    ),
    notDeleted: valueOrDefault(
      ((config || {}).notifications || {}).notDeleted,
      false
    ),
    notFetched: valueOrDefault(
      ((config || {}).notifications || {}).notFetched,
      false
    ),
    notUpdated: valueOrDefault(
      ((config || {}).notifications || {}).notUpdated,
      false
    ),
  },
  showFetchLoader: valueOrDefault((config || {}).showFetchLoader, true),
  showSubmitLoader: valueOrDefault((config || {}).showSubmitLoader, false),
  showReset: valueOrDefault((config || {}).showReset, false),
  showTitle: valueOrDefault((config || {}).showTitle, true),
  submitLabel: valueOrDefault((config || {}).submitLabel, null),
  title: valueOrDefault((config || {}).title, null),
});

export const withMasterDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    fetched: valueOrDefault(
      ((config || {}).notifications || {}).fetched,
      false
    ),
    notFetched: valueOrDefault(
      ((config || {}).notifications || {}).notFetched,
      true
    ),
  },
});

export const withNewDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    created: valueOrDefault(((config || {}).notifications || {}).created, true),
    notCreated: valueOrDefault(
      ((config || {}).notifications || {}).notCreated,
      true
    ),
  },
});

export const withDeleteDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    deleted: valueOrDefault(((config || {}).notifications || {}).deleted, true),
    notDeleted: valueOrDefault(
      ((config || {}).notifications || {}).notDeleted,
      true
    ),
  },
});

export const withDetailDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    fetched: valueOrDefault(
      ((config || {}).notifications || {}).fetched,
      false
    ),
    notFetched: valueOrDefault(
      ((config || {}).notifications || {}).notFetched,
      true
    ),
  },
});

export const withEditDefaultNotificationConfig = (config) => ({
  ...config,
  notifications: {
    ...(config.notifications || {}),
    fetched: valueOrDefault(
      ((config || {}).notifications || {}).fetched,
      false
    ),
    updated: valueOrDefault(((config || {}).notifications || {}).updated, true),
    notFetched: valueOrDefault(
      ((config || {}).notifications || {}).notFetched,
      true
    ),
    notUpdated: valueOrDefault(
      ((config || {}).notifications || {}).notUpdated,
      true
    ),
  },
});

export const makeId = (length) => {
  let result = "";
  const characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  const charactersLength = characters.length;

  for (var i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }

  return result;
};
