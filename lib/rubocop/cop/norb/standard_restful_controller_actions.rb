# frozen_string_literal: true

module RuboCop
  module Cop
    module Norb
      # This cop checks that Rails Controllers only use standard RESTful actions
      # (`index`, `show`, `new`, `edit`, `create`, `update` and `destroy`).
      # Limiting controllers to only the standard RESTful actions helps ensure
      # controllers have single responsibility.
      #
      # If a new action is not needed that doesn't fit within a controller,
      # create a new Controller to handle that action. Adding too many actions
      # to an already full controller bloats that controller. Often that new
      # controller with a single action will soon include additional related actions.
      #
      # While following this rule will create more controllers, they will each
      # independently be more simple.
      #
      # @example
      #   # bad
      #   class BlogController < ApplicationController
      #     def ajax_comments
      #     end
      #   end
      #
      #   # good
      #   class BlogCommentsController < ApplicationController
      #     def index
      #     end
      #   end
      #
      class StandardRestfulControllerActions < Cop
        include DefNode

        MSG = '`%<action>s` is not a standard RESTful controller action.'
        RESTFUL_ACTIONS = %i[index show new edit create update destroy].freeze

        def_node_matcher :restful?, <<-PATTERN
          (def {#{RESTFUL_ACTIONS.map(&:inspect).join(' ')}} ...)
        PATTERN

        def_node_matcher :method, <<-PATTERN
          (def $_ ...)
        PATTERN

        def on_def(node)
          return if restful?(node) || non_public?(node)
          add_offense(node)
        end

        def message(node)
          format(MSG, action: method(node))
        end
      end
    end
  end
end
