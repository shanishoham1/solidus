# Solidus Admin

A Rails engine that provides an administrative interface to the Solidus ecommerce platform.

## Overview

- Based on ViewComponent and TailwindCSS
- Uses StimulusJS and Turbo for interactivity
- Works as a separate engine with its own routes
- Uses the same models as the main Solidus engine
- Has its own set of controllers

## Installation

Install `solidus_admin` by adding it to your Gemfile and running the installer generator

```bash
bundle add solidus_admin
bin/rails g solidus_admin:install
```

If you're using an authentication system other than `solidus_auth_devise` you'll need to manually configure authentication methods (see api documentation for `SolidusAdmin::Configuration`).

### Components

See [docs/contributing/components.md](docs/components.md) for more information about components.

### Using it alongside `solidus_backend`

`solidus_backend` is the official admin interface for Solidus while `SolidusAdmin` is still in the works and not completed. `SolidusAdmin` acts as a drop-in replacement for `solidus_backend` and over time it will cover more and more of the existing functionality.

Meanwhile it is possible to use both `solidus_backend` and `SolidusAdmin` in the same application by mounting the
`SolidusAdmin` engine before `Spree::Core::Engine`.

By using a route `constraint` it is possible to shadow any of the routes from `solidus_backend` with the ones from `SolidusAdmin`.

By default the `SolidusAdmin` routes will be disabled if a cookie named `solidus_admin` contains the value `false` or if a query parameter named `solidus_admin` contains the value `false`. This allows to easily switch between the two admin interfaces.

The constraint is installed in the host application routes file and thus it is possible to override it or to add more complex logic to it.

```ruby
# config/routes.rb
mount SolidusAdmin::Engine, at: '/admin', constraints: ->(req) {
  $redis.get('solidus_admin') == 'true' # or any other logic
}
```

### Authentication & Authorization

- Delegates authentication to `solidus_backend` and relies on `solidus_core` for authorization

## Development

- [Customizing tailwind](docs/customizing_tailwind.md)
- [Customizing view components](docs/customizing_view_components.md)
- [Customizing the main navigation](docs/customizing_menu_items.md)

### Adding components to Solidus Admin

When using the component generator from within the admin folder it will generate the component in the library
instead of the sandbox application.

```bash
# the `solidus_admin/` namespace is added by default
bin/rails admin g solidus_admin:component foo
      create  app/components/solidus_admin/foo/component.rb
      create  app/components/solidus_admin/foo/component.html.erb
      create  app/components/solidus_admin/foo/component.yml
      create  app/components/solidus_admin/foo/component.js
      create  spec/components/solidus_admin/foo/component_spec.rb
```

## Releasing

1. Update the version in `lib/solidus_admin/version.rb`
2. Commit the changes with the message `Release solidus_admin/v1.2.3`
3. `cd admin; bundle exec rake release`
4. Manually release on GitHub
