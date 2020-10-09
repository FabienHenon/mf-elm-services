# mf-elm-services

Elm services to be used in micro frontends within the maestro

It contains the following modules:

* `Services.EventManager`: to emit and listen for maestro events
* `Services.Navigation`: to block/unblock maestro navigation
* `Services.Realtime`: to handle realtime communication with backend
* `Services.Notifications`: to display notifications from the maestro
* `Services.Data`: that generates a json payload for success and error requests/notifications
* `Services.Validations`: that handles form validation

_Please refer to [mf-elm-bootstrap](https://github.com/calions-app/mf-elm-bootstrap) for code examples_

You also have several usefull functions in JS to make your configuration (for Elm flags):

* `makeComponentConfig`: Make a configuration for Elm flags with some default values
* `withMasterDefaultNotificationConfig`: Make the default configuration for notifications in `master` view
* `withNewDefaultNotificationConfig`: Make the default configuration for notifications in `new` view
* `withEditDefaultNotificationConfig`: Make the default configuration for notifications in `edit` view
* `withDetailDefaultNotificationConfig`: Make the default configuration for notifications in `detail` view
* `withDeleteDefaultNotificationConfig`: Make the default configuration for notifications in `delete` view

Here is how to use it:

```js
makeComponentConfig(withMasterDefaultNotificationConfig({
  closable: true,
  searchable: true,
  notifications: {
    fetched: true
  }
}))
```

This will generate the following configuration (due to the default values):

```js
{
  closable: true,           // Shows a button to close the MF
  closeTitle: null,         // Changes the text for the close button
  customEvents: [],         // Events to be added in a dropdown menu in master and detail views
  editable: false,          // Shows a button to edit the entity
  deletable: false,         // Shows a button to deelte the entity
  loadingButtonLabel: null, // Label to use in form submit button when entity is creating/updating (defaults to a loader)
  searchable: true,         // Shows a search form for master views
  newable: false,           // Shows a button to create a new entity
  notifications: {          // Shows notification instead of plain text for the following events
    created: false,
    deleted: false,
    fetched: true,
    updated: false,
    notCreated: false,
    notDeleted: false,
    notFetched: true,
    notUpdated: false
  },
  showFetchLoader: true,    // Shows a loader in edit views when the entity is loading
  showSubmitLoader: false,  // Shows a loader in edit/new views when the enitty is creating
  showReset: false,         // Shows a reset button in form views (new/edit)
  showTitle: true,          // Shows a title for the MF
  submitLabel: null,        // Changes the submit button label in forms
  title: null,              // Changes the title of the MF
}
```

_To know what are the default values for the configuration see the `index.js` source file_

## Install

Add this package to your node modules:

```
$ npm install --save mf-elm-services
```

Import the ports to your JS code after initializing the Elm application:

```js
import Elm from './components/Main.elm';
import { initMaestroPorts, makeComponentConfig } from 'mf-elm-services/src/index.js';

function start(appNode, params, options) {
  console.log(`%cstarting ${options.groupRef}`, "color:violet", params, options);

  const app = Elm.Main.init({
    node: appNode,
    flags: {
      env: process.env.NODE_ENV,
      seed: new Date().getTime(),
      languages: navigator.languages || [],
      apiBaseUrl: process.env.API_BASE_URL,
      domainName: 'micro-frontend-domain',
      config: makeComponentConfig(params)
    }
  });

  // Update languages choices from browser
  window.addEventListener('languagechange', function () {
    app.ports.portOnLanguagesChange.send(navigator.languages || []);
  });

  initMaestroPorts(app, options);
}

function stop(appNode, options) {
  console.log(`%cstopping ${options.groupRef}`, "color:orange", options);
}

window.MfMaestro.registerMicroApp("micro-frontend-domain-entity-detail", { start, stop });

```

Add the Elm source code to your `source-directories` in your `elm.json` file:

```json
{
    "type": "application",
    "source-directories": [
        "src/components",
        "node_modules/mf-elm-services/src/elm"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "FabienHenon/jsonapi": "2.0.2",
            "calions-app/app-object": "1.0.0",
            "calions-app/env": "1.0.0",
            "calions-app/jsonapi-http": "1.0.1",
            "calions-app/remote-resource": "1.0.0",
            "calions-app/test-attribute": "1.0.0",
            "elm/browser": "1.0.1",
            "elm/core": "1.0.2",
            "elm/html": "1.0.0",
            "elm/http": "2.0.0",
            "elm/json": "1.1.3",
            "elm/random": "1.0.0",
            "elm/time": "1.0.0",
            "elm/url": "1.0.0",
            "elm-explorations/markdown": "1.0.0",
            "rtfeldman/elm-css": "16.0.1"
        },
        "indirect": {
            "Skinney/murmur3": "2.0.8",
            "elm/bytes": "1.0.8",
            "elm/file": "1.0.5",
            "elm/parser": "1.1.0",
            "elm/virtual-dom": "1.0.2",
            "elm-community/json-extra": "4.0.0",
            "elm-community/list-extra": "8.2.2",
            "krisajenkins/remotedata": "6.0.1",
            "rtfeldman/elm-hex": "1.0.0",
            "rtfeldman/elm-iso8601-date-strings": "1.1.3"
        }
    },
    "test-dependencies": {
        "direct": {
            "elm-explorations/test": "1.2.2"
        },
        "indirect": {}
    }
}
```