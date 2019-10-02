You need to tell RuboCop to load the Norb extension. There are three
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-norb
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
