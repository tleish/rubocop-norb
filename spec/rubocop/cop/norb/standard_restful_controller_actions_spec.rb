# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::StandardRestfulControllerActions, :config do
  context 'when valid controller method constucts' do
    it 'accepts usages of standard Rails RESTFul actions' do
      expect_no_offenses(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def index; end
            def show; end
            def new; end
            def edit; end
            def create; end
            def update; end
            def destroy; end
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

            def my_private_method; end
          end
        end
      RUBY
    end
  end

  context 'when invalid controller method constucts' do
    it 'registers an offense for ajax_products' do
      expect_offense(<<~RUBY)
        module Blog
          class PostController < ApplicationController
            def index; end

            def ajax_products; end
            ^^^^^^^^^^^^^^^^^^^^^^ `ajax_products` is not a standard RESTful controller action.
          end
        end
      RUBY
    end
  end
end
