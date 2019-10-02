# Norb

## Norb/MisplacedBranchingLogic

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | 0.75 | -

This cop ensures branching logic is only in business classes
if/else/rescue/and/&&/or/||.

### Examples

#### Controller Callback

```ruby
# bad
class UserController < ApplicationController
  def show
    @user = User.find(params)
    redirect_to users_home_path(@user.id) if @user.valid?
  end
end

# good
class UserController < ApplicationController
  def show
    @user = User.find(params)
    @user.with_id do |id|
      redirect_to users_home_path(id)
    end
  end
end

class User
  #...
  def with_id
    yield(id) if valid?
  end
end
```
#### Controller Rescue Callback

```ruby
# bad
class ArticleController < ApplicationController
  def delete
    @article = Article.find(params[:id])
    begin
      @article.delete
      flash[:alert] = "Deleted Records"
      redirect_to action: 'index'
    rescue DeleteException => error
      flash[:error] = error.message
      redirect_to home_path(params[:id])
    end
  end
end

# good
class ArticleController < ApplicationController
  def delete
    @article = Article.find(params[:id])
    @article.delete
    @article.success do
      flash[:alert] = "Deleted Records"
      redirect_to action: 'index'
    end
    @article.failure do |error|
      flash[:error] = error
      redirect_to home_path(params[:id])
    end
  end
end

class Article
  attr_accessor :error
  def delete
    destroy
  rescue => error
    @error = error.message
  end

  def success
    yield unless @error
  end

  def failure
    yield(@error) if @error
  end
end

# good
# Nested inside delete using `on` variable, yielding `self` on business class for delete

class ArticleController < ApplicationController
  def destroy
    @article = Article.find(params[:id])
    @article.delete do |on|
      on.success do
        flash[:alert] = "Deleted Records"
        redirect_to action: 'index'
      end
      on.failure do |error|
        flash[:error] = error
        redirect_to home_path(params[:id])
      end
    end
  end
end

class Article
  def delete
    destroy
  rescue => error
    @error = error.message
  ensure
    yield self
  end

  def success
    yield unless @error
  end

  def failure
    yield(@error) if @error
  end
end

# good
# Nested inside delete using `on` variable, using generic AttemptCallback class

class ArticleController < ApplicationController
  def destroy
    @article = Article.find(params[:id])
    @article.delete do |on|
      on.success do
        flash[:alert] = "Deleted Records"
        redirect_to action: 'index'
      end
      on.failure do |error|
        flash[:error] = error
        redirect_to home_path(params[:id])
      end
    end
  end
end

class Article
  def delete
    destroy
  rescue => error
    @error = error.message
  ensure
    yield AttemptCallback.new(error: @error)
  end
end

class AttemptCallback
  attr_accessor :error

  def initialize(error: nil)
    @error = error
  end

  def success
    yield unless error
  end

  def failure
    yield(error) if error
  end
end
```
#### View Callback

```ruby
# bad
<<~ERB
  <menu>
    <ul>
      <li>Home</li>
      <li>Product</li>
      <li>Contact</li>
      <% if @user.admin? %>
        <li>Admin</li>
      <% end %>
    </ul>
  </menu>
ERB

# good
class UserFinder
  #...
  def admin_role
    yield if user.type == 'admin'
  end
end

<<~ERB
  <menu>
    <ul>
      <li>Home</li>
    <li>Product</li>
    <li>Contact</li>
    <% @user.admin_role do %>
      <li>Admin</li>
    <% end %>
    </ul>
  </menu>
ERB
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
BranchMethods | `if`, `and`, `or`, `case`, `resbody` | Array
Include | `app/models/ar/**/*.rb`, `app/controllers/**/*.rb`, `app/views/**/*.erb` | Array
