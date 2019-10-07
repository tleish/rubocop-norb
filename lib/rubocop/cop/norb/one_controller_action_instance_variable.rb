# frozen_string_literal: true

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Norb
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @example EnforcedStyle: bar (default)
      #   # bad
      #   class BlogController < ApplicationController
      #     def index
      #       @post = Post.new(blog_id: param[:id])
      #       @comments = Comment.new(blog_id: param[:id])
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class BlogController < ApplicationController
      #     def index
      #       @blog_post = BlogPost.new(id: param[:id])
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class BlogController < ApplicationController
      #     def index
      #       # no instance variables
      #     end
      #   end
      #
      class OneControllerActionInstanceVariable < Cop
        include DefNode
        MSG = '`%<action>s` instantiates more than one @instance variable.'

        def_node_matcher :method, <<-PATTERN
          (def $_method_name ...)
        PATTERN

        def_node_search :instance_variable_names, <<-PATTERN
            (ivasgn $_instance_variable_name ...)
        PATTERN

        def on_def(node)
          return if non_public?(node) || instance_variable_names(node).uniq.count <= 1
          add_offense(node)
        end

        private

        def message(node)
          format(MSG, action: method(node))
        end
      end
    end
  end
end
