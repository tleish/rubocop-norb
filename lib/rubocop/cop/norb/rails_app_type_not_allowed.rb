# frozen_string_literal: true

module RuboCop
  module Cop
    module Norb
      # This cop ensures restricted rails/app/[types] are not allowed
      #
      # @example
      #   # bad
      #   app/helpers/foo_helper.rb
      #
      #   # good
      #   app/models/foo.rb
      class RailsAppTypeNotAllowed < Base
        MSG = 'This Rails app/%{type} type is not allowed.'
        FILE_REGEX = %r{app/(?<type>[A-Za-z]+)/.*\.rb$}
        include RangeHelp

        def on_new_investigation
          range = source_range(processed_source.buffer, 1, 0)
          app = processed_source.file_path.match FILE_REGEX
          return unless app
          add_offense(range, message: format(MSG, type: app[:type]))
        end
      end
    end
  end
end
