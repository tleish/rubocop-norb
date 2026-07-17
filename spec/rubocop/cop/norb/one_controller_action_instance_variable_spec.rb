# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::OneControllerActionInstanceVariable, :config do
  context 'when valid controller method constructs' do
    it 'accepts usages of no instance variable' do
      expect_no_offenses(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def index; end
          end
        end
      RUBY
    end

    it 'accepts usages of one instance variable' do
      expect_no_offenses(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def index
              @instance_one = MyClass.new
            end
          end
        end
      RUBY
    end

    it 'accepts usages of one instance variable declared twice' do
      expect_no_offenses(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def index
              if true
                @instance_one = MyClass.new
              else
                @instance_one = MyClassOther.new
              end
            end
          end
        end
      RUBY
    end

    it 'accepts usages of class methods' do
      expect_no_offenses(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def self.my_class_method; end
          end
        end
      RUBY
    end

    it 'accepts usages of private methods' do
      expect_no_offenses(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            private

            def index
              @instance_one = MyClass.new
              @instance_two = MyClassOther.new
            end
          end
        end
      RUBY
    end
  end

  context 'when invalid controller method constructs' do
    it 'registers an offense for too_many' do
      expect_offense(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def too_many
            ^^^^^^^^^^^^ `too_many` instantiates more than one @instance variable.
              @instance_one = MyClass.new
              @instance_two = MyClassOther.new
            end
          end
        end
      RUBY
    end

    it 'registers an offense for too_many_with_nesting' do
      expect_offense(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def too_many_with_nesting
            ^^^^^^^^^^^^^^^^^^^^^^^^^ `too_many_with_nesting` instantiates more than one @instance variable.
              @instance1 = MyClass.new
              if bool = true
                @instance2 = MyClassOther.new
              end
            end
          end
        end
      RUBY
    end
  end
end
