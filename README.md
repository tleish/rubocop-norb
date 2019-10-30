# RuboCop Norb

A [RuboCop](https://github.com/rubocop-hq/rubocop) extension focused on enforcing NORB (None of Rails Business).  An opinionated approach to separating business logic from Rails framework code.

## Installation

Just install the `rubocop-norb` gem

```sh
gem install rubocop-norb
```

or if you use bundler put this in your `Gemfile`

```ruby
gem 'rubocop-norb'
```

## Usage

You need to tell RuboCop to load the Norb extension. There are three ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-norb
```

Alternatively, use the following array notation when specifying multiple extensions.

```yaml
require:
  - rubocop-other-extension
  - rubocop-norb
```

Now you can run `rubocop` and it will automatically load the RuboCop Norb
cops together with the standard cops.

### Command line

```sh
rubocop --require rubocop-norb
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-norb'
end
```

## The Cops

All cops are located under
[`lib/rubocop/cop/norb`](lib/rubocop/cop/norb), and contain
examples/documentation.

In your `.rubocop.yml`, you may treat the Norb cops just like any other
cop. For example:

```yaml
Norb/BranchingLogic:
  Include:
    - app/controllers/**/*.rb
```

## Contributing

Checkout the [contribution guidelines](CONTRIBUTING.md).

## License

`rubocop-norb` is MIT licensed. [See the accompanying file](LICENSE.txt) for
the full text.

## Credit

Credit goes to [Bozhidar Batsov](https://github.com/bbatsov) and other [RuboCop](https://github.com/rubocop-hq/rubocop) contributors for the great Rubocop framework of this gem.
