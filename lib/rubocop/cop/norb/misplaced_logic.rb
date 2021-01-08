# frozen_string_literal: true

module RuboCop
  module Cop
    module Norb
      # This cop checks to make sure we keep business logic together in designated places.
      #
      # For example, the preferred location for helper code should be in business models
      # or lib so that business logic is kept separate from Rails code.
      #
      # @example
      #   # bad
      #   # app/helpers/blog_helper.rb
      #
      #   # good
      #   # app/models/blog/comments.rb
      #
      class MisplacedLogic < Cop
        include RangeHelp
        MSG = 'Code should only be placed in %<exclude>s.'

        def investigate(processed_source)
          range = source_range(processed_source.buffer, 1, 0)
          add_offense(nil, location: range, message: custom_message)
        end

        private

        def custom_message
          format(MSG, exclude: cop_config['Exclude'].to_a.join('|'))
        end
      end
    end
  end
end
