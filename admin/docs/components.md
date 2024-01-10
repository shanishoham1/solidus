# Components

Components are the main building blocks of the admin interface. They are implemented as ViewComponents and are rendered directly by the controllers.

The following documentation assumes that you are familiar with ViewComponents, if you are not please refer to the [ViewComponent documentation](https://viewcomponent.org/guide/).

We have two types of components:

- **UI components** are the building blocks of the interface. They are usually small components that are used to build more complex components and are generic enough to be reused in different contexts. UI components are defined under the `app/components/solidus_admin/ui` folder.
- **Page components** are the main components that are rendered by the controllers. They are usually full page components that are rendered directly by the
  controllers, they are defined under the `app/components/solidus_admin` following the name of the controller and action they are used in, e.g. `app/components/solidus_admin/orders/index/component.rb` is the component that is rendered by the `SolidusAdmin::OrdersController#index` action.

## Generating components

Components can be generated using the `solidus_admin:component` generator combined with the `bin/rails` command from the solidus repository.

```shell
$ bin/rails admin g solidus_admin:component foo
      create  app/components/solidus_admin/foo/component.rb
      create  app/components/solidus_admin/foo/component.html.erb
      create  app/components/solidus_admin/foo/component.yml
      create  app/components/solidus_admin/foo/component.js
```

Using `bin/rails admin` will run the generator from the `solidus_admin` engine, instead of the sandbox application.

## Coding style

Especially for UI components it's better to only accept simple Ruby values in the initializer, and use alternative constructors to accept more complex objects. This makes the components easier to use and test. E.g.:

```ruby
# bad

class SolidusAdmin::UI::OrderStatus::Component < ViewComponent::Base
  def initialize(order:)
    @order = order
  end
end

# good

class SolidusAdmin::UI::OrderStatus::Component < ViewComponent::Base
  def initialize(status:)
    @status = status
  end

  def self.for_order(order)
    new(status: order.status)
  end
end
```

For style variations within the component we picked the name `scheme` instead of `variant` to avoid confusion with product variants.

For size variations we use the name `size` with single letter values, e.g. `s`, `m`, `l`, `xl`, `xxl`.

For text content we picked the name `text` instead of `name` to avoid confusion with the `name` attribute of the HTML tag.

## Component registry

Components are registered in the `SolidusAdmin::Config.components` registry. This is done to allow replacing components for customization purposes and to allow components to be deprecated between versions.

In order to retrieve component classes from the registry you can call the `component` helper from within controllers and components inheriting from `SolidusAdmin::BaseComponent` or including `SolidusAdmin::ComponentHelper`, e.g. `component('ui/button')` will fetch `SolidusAdmin::UI::Button::Component`.


## When to use UI vs. Page components

Generally new components will be built for a specific controller action and will be used only in that action. In this case it is better to use a Page component and define it under the namespace of the action, e.g. `app/components/solidus_admin/orders/index/payment_status/component.rb`.

If a component is used by multiple actions of the same controller it can be moved to the controller namespace, e.g. `app/components/solidus_admin/orders/payment_status/component.rb`.

Whenever a component is used by multiple controllers you can choose between duplicating it in multiple places or moving it to the `ui` namespace.

Even if counter intuitive, duplicating in many cases is beneficial because it allows to change the component in one place without affecting other components that might be using it. Eventually the two copies will share generic enough code that it can be extracted to a UI component.

UI components should be very generic and reusable, but they should not anticipate all the possible use cases, rather they should be extracted from existing components that are already used in multiple places. This has prooved to be the most effective way to build UI components, as we discovered that anticipating theoretical use cases ends up in over-engineered code that eventually needs to be adapted to the actual use cases or is never used at all.

## Naming conventions

The project uses a naming convention for components that is slightly different from the ViewComponent default. This is done to make it super-easy to rename components and move them around.

All component related files have a base name that is `component`, each with its own extension, and are placed in a folder that is named after the component class they define.

E.g. `app/components/solidus_admin/orders/index/payment_status/component.rb` defines the `SolidusAdmin::Orders::Index::PaymentStatus::Component` class.

In this way in order to rename the component is sufficient to rename the folder and the class name, without having to change the name of all the files.

## Translations

Components can define their own translations in the `component.yml` file and they're expected to be self contained. This means that translations defined in `solidus_core` should not be used in components.

Please refer to the [ViewComponent documentation](https://viewcomponent.org/guide/translations.html) for more information.

## Previews and Lookbook

For UI components we leverage the [ViewComponent previews](https://viewcomponent.org/guide/previews.html) combined with [Lookbook](https://lookbook.build) to provide a live preview of the component. This is very useful to get an overview of how the component looks and how it can be changed using the different arguments.

We have found that trying to create previews for page components is very hard and error-prone, as they usually require a more elaborate context to be rendered. For this reason we don't use previews for page components, except for the most basic ones
if they have a wide range of arguments and we want to cover all combinations.

In order to inspect previews it's enough to visit `/lookbook` in the browser on a running server.

## Testing

Components are tested differently depending on whether they are UI or Page components. UI components are tested in isolation, while Page components, that usually demand a more elaborate context, are tested through feature specs.

For UI components we leverage previews to achieve maximum coverage of the UI components. For most basic components it is enough, more complex components might require additional specs. This has proven to minimize maintenance and code-churn on the spec code and avoid repeating the code to render the component passing different arguments.

Page components are tested in the context of the controller action they are used in, e.g. `admin/spec/features/orders_spec.rb` will cover interactions with the order listing and indirectly test the `SolidusAdmin::Orders::Index::Component` class among others. We have found that this is the most effective way to test page components, as trying to recreate the context needed for them in isolation is very hard and error-prone.

This is not a hard rule, if you find that a Page component requires to be tested in isolation or that a UI component requires a more elaborate context you can always write additional specs.
