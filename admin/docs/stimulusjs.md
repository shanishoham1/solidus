# StimulusJS

This project uses [StimulusJS](https://stimulusjs.org) to add interactivity to the admin interface.

## Using ther `stimulus_id` helper

All JavaScript files are imported with import-maps so there's no need to compile them.
Any `component.js` is automatically loaded as a StimulusJS controller using the component path
as the identifier (via `parameterize` plus transforming `/` into `--`),
e.g. `app/components/solidus_admin/foo/component.js` is loaded as `solidus-admin--foo`.

A `stimulus_id` helper is provided to make it easier to use StimulusJS controllers in the components without having to
get the controller identifier right every time.

```erb
<div
  data-controller="<%= stimulus_id %>"
  data-action="click-><%= stimulus_id %>#doSomething"
  data-<%= stimulus_id %>-foo-value="123"
>
  ...
</div>
```

## Coding Style

Besides the standard StimulusJS conventions we have a few additional tricks to make the code more readable and maintainable.

### Separating the state from the DOM

Whenever the controller gets beyond trivial we try to separate the state from DOM updates using a `render()` method.

```js
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "details" ]

  connect() {
    this.render()
  }

  show() {
    this.open = true
  }

  render() {
    this.detailsTarget.hidden = !this.open
  }
}
```

### Using values to communicate with the external world

Values are a great way to communicate with the external world and represent state.
Any change to them will be reflected in the DOM and the change callbacks provided by StimulusJS
are a great way to react to changes in the state.

```js
import { Controller } from "stimulus"

export default class extends Controller {
  static values = { open: Boolean }

  connect() {
    this.render()
  }

  show() {
    this.openValue = true
  }

  openValueChanged() {
    this.render()
  }

  render() {
    this.detailsTarget.hidden = !this.openValue
  }
}
```

## StimulusUse
