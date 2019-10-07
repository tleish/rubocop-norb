# Norb

## Norb/ActiveRecordNamespaced

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | - | -

This cop checks to see if an ActiveRecord model is namespaced.
Namespacing ActiveRecord models (e.g. Ar::) allows ActiveRecord to be
separated from business logic, without conflicting names.

### Examples

```ruby
# bad
# app/models/user.rb
class User < ActiveRecord::Base
end

# good
# app/models/ar/user.rb
module Ar
  class User < ActiveRecord::Base
    self.table_name = 'user'
  end
end

# good
# app/models/ar.rb
module Ar
  # remove the auto 'ar_' prefix from namespaced Ar::Model(s)
  def self.table_name_prefix
    ''
  end
end

# app/models/ar/user.rb
module Ar
  class User < ActiveRecord::Base
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
ActiveRecordNamespace | `Ar` | String
ActiveRecordSuperclasses | `ActiveRecord`, `ApplicationRecord` | Array
Include | `app/models/**/*.rb` | Array

## Norb/ActiveRecordThroughBusiness

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | - | -

This cop checks to see if ActiveRecord namespace is being called non-business objects.
Separation of controllers, views, jobs and other node objects should go through
business logic in order to separate direct access to databases.

Note: namespace config from `Norb/ActiveRecordNamespaced` settings

### Examples

```ruby
# bad
# app/controllers/article_controller.rb
class ArticleController < ApplicationController
  def show
    Ar::Article.find(params[:id])
  end
end

# good
# app/controllers/article_controller.rb
class ArticleController < ApplicationController
  def show
    Article.for(params[:id])
  end
end

# app/models/article.rb
class Article
  def self.for(id)
    Ar::Article.find(id)
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/models/**/*.rb` | Array

## Norb/MisplacedBranchingLogic

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | - | -

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

## Norb/MisplacedLogic

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | - | -

This cop checks to make sure we keep business logic together in designated places.

For example, the preferred location for helper code should be in business models
or lib so that business logic is kept separate from Rails code.

### Examples

```ruby
# bad
# app/helpers/blog_helper.rb

# good
# app/models/blog/comments.rb
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/**/*.rb` | Array
Exclude | `app/models/**/*.rb`, `app/controllers/**/*.rb`, `app/views/**/*.rb` | Array

## Norb/OneControllerActionInstanceVariable

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | - | -

TODO: Write cop description and example of bad / good code. For every
`SupportedStyle` and unique configuration, there needs to be examples.
Examples must have valid Ruby syntax. Do not use upticks.

### Examples

#### EnforcedStyle: bar (default)

```ruby
# bad
class BlogController < ApplicationController
  def index
    @post = Post.new(blog_id: param[:id])
    @comments = Comment.new(blog_id: param[:id])
    # ...
  end
end

# good
class BlogController < ApplicationController
  def index
    @blog_post = BlogPost.new(id: param[:id])
    # ...
  end
end

# good
class BlogController < ApplicationController
  def index
    # no instance variables
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/controllers/**/*_controller.rb` | Array

## Norb/StandardRestfulControllerActions

Enabled by default | Safe | Supports autocorrection | VersionAdded | VersionChanged
--- | --- | --- | --- | ---
Enabled | Yes | No | - | -

This cop checks that Rails Controllers only use standard RESTful actions
(`index`, `show`, `new`, `edit`, `create`, `update` and `destroy`).
Limiting controllers to only the standard RESTful actions helps ensure
controllers have single responsibility.

If a new action is not needed that doesn't fit within a controller,
create a new Controller to handle that action. Adding too many actions
to an already full controller bloats that controller. Often that new
controller with a single action will soon include additional related actions.

While following this rule will create more controllers, they will each
independently be more simple.

### Examples

```ruby
# bad
class BlogController < ApplicationController
  def ajax_comments
  end
end

# good
class BlogCommentsController < ApplicationController
  def index
  end
end
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
Include | `app/controllers/**/*_controller.rb` | Array
