# Writing index pages

Index pages are common in the admin interface, and they are used to display a list of records of a specific model.

Given that they tend to all look the same, we have a component that can be used to build them that will avoid having to write boilerplate code.

## The `index` action

The `index` action is the standard action used to display index pages. It's a standard `GET` action that will render the `index` component.

In order to support search scopes and filters the controller should include the `SolidusAdmin::ControllerHelpers::Search` module and call
`apply_search_to` as follows:

```ruby
class SolidusAdmin::UsersController < SolidusAdmin::BaseController
  include SolidusAdmin::ControllerHelpers::Search

  def index
    users = apply_search_to(Spree.user_class.order(id: :desc), param: :q)
    # ...
```

Pagination support requires the index action to also call the `set_page_and_extract_portion_from` method provided by the
`geared_pagination` gem. This method will set the `@page` instance variable to the paginated collection and will return the
portion of the collection to be displayed in the current page.

```ruby
def index
  users = apply_search_to(Spree.user_class.order(id: :desc), param: :q)
  set_page_and_extract_portion_from(users)
  # ...
```

Finally the index action should render the `index` component passing the `@page` instance variable as the `collection` prop.

```ruby
def index
  users = apply_search_to(Spree.user_class.order(id: :desc), param: :q)
  set_page_and_extract_portion_from(users)
  render component('users/index').new(page: @page)
end
```

## The `ui/pages/index` component

The `ui/pages/index` component is an abstract component providing sensible defaults for index pages along with template methods that can be used
to customize the behavior of index pages.

We encourage to look at existing index pages and to the UI component itself to understand how it works, here we'll cover the most important parts.

The index component expects only the `page` argument at initialization, everything else is provided through template methods.

```ruby
class SolidusAdmin::Users::Index < Solidus::Admin::UI::Pages::Index
  def model_class
    Spree.user_class
  end
end

render component('users/index').new(page: @page)
```

## Batch Actions

Batch actions are actions that can be performed on multiple records at the same time. The index page uses the `ui/table` component internally and
will rely on the `batch_actions` method to render the batch actions dropdown.

In the component batch actions are provided as an Array of Hashes, each Hash representing a single batch action. The Hash must contain the following keys:

- `label`: the name of the batch action, this will be used as the label of the dropdown item
- `icon`: the remix icon-name to be used as the icon of the dropdown item (see the `ui/icon` component for more information)
- `action`: the name of the action to be performed when the batch action is selected, this is a URL or a path
- `method`: the HTTP method to be used when performing the action, e.g. `:delete`

The `batch_actions` method is called in the context of the controller, so you can use any controller method or helper to build the batch actions.

Batch actions will be submitted to the specified action with an `id` parameter containing the ids of the selected records. Using `id` as the
parameter name is a way to have the same action support both batch and single-record actions for standard routes.

E.g.

```ruby
# in the component
def batch_actions
  [
    {
      label: "Delete",
      icon: "trash",
      action: solidus_admin.delete_admin_users_path,
      method: :delete
    }
  ]
end
```

```ruby
# in the controller
def delete
  @users = Spree.user_class.where(id: params[:id])
  @users.destroy_all
  flash[:success] = "Admin users deleted"
  redirect_to solidus_admin.users_path, status: :see_other
end
```

## Search Scopes

Search scopes are a way to filter the records displayed in the index page. The index page uses the `ui/table` component internally and
will rely on the `scopes` method to render the search scopes buttons.

In the component search scopes are provided as an Array of Hashes, each Hash representing a single search scope. The Hash must contain the following keys:

- `label`: the name of the search scope, this will be used as the label of the button
- `name`: the name of the search scope, this will be sent as the `q[scope]` parameter when the button is clicked
- `default`: whether this is the default search scope, this will be used to highlight the button when the page is loaded

On the controller side search scopes can be defined with the `search_scope` helper, as provided by `SolidusAdmin::ControllerHelpers::Search`,
which takes a name, an optional `default` keyword argument, and a block. The block will be called with the current scope and should return
a new ActiveRecord scope.

E.g.

```ruby
module SolidusAdmin
  class UsersController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:customers, default: true) { _1.left_outer_joins(:role_users).where(role_users: { id: nil }) }
    search_scope(:admin) { _1.joins(:role_users).distinct }
    search_scope(:with_orders) { _1.joins(:orders).distinct }
    search_scope(:without_orders) { _1.left_outer_joins(:orders).where(orders: { id: nil }) }
    search_scope(:all)

    def index
      users = apply_search_to(Spree.user_class.order(id: :desc), param: :q)
      # ...
```

## Filters

Filters are a way to filter the records displayed in the index page. The index page uses the `ui/table/ransack_filter` component internally and
will rely on the `filters` method to render the filters dropdown.

In the component filters are provided as an Array of Hashes, each Hash representing a single filter. The Hash must contain the following keys:

- `label`: the name of the filter, this will be used as the label in the filter bar
- `attribute`: the name of the ransack-enabled attribute to be filtered
- `predicate`: the name of the ransack predicate to be used, e.g. `eq`, `in`, `cont`
- `options`: an Array of options to be used for the filter, this is in the standard rails form of `[["label", "value"], ...]`

On the controller side it's enough to add ransack support to the index action by including `SolidusAdmin::ControllerHelpers::Search` and calling
`apply_search_to` as explained in the [Index action](#index-action) section.
