# frozen_string_literal: true

module RuboCop
  module Cop
    module Norb
      # This cop checks for binary logic in non-business code.
      #
      # It covers arithmetic operators: `+`, `-`, `*`, `/`, `%`, `**`;
      # comparison operators: `==`, `eql?`, `equal?`, `===`, `=~`, `>`, `>=`, `<`, `<=`, `!`, `not`;
      # bitwise operators: `|`, `^`, `&`, `<<`, `>>`;
      # boolean operators: `&&`, `||`
      # and "spaceship" operator - `<=>`.
      #
      class BinaryOperation < Cop
        MSG = 'This comparison operator logic is not allowed here.'

        COMPARISON_OPERATORS = %i[== === != eql? equal? =~ !~ < > <=> <= >=].freeze
        ASSIGNMENT_OPERATORS = %i[!].freeze
        BITWISE_OPERATORS = %i[| ^ & << >>].freeze
        MATH_OPERATORS = %i[+ - * / % ** << >> | ^].freeze
        RESTRICT_ON_SEND = (COMPARISON_OPERATORS + ASSIGNMENT_OPERATORS + MATH_OPERATORS + BITWISE_OPERATORS).freeze

        def on_send(node)
          add_offense(node)
        end

        def on_and(node)
          add_offense(node)
        end
        alias on_or on_and
      end
    end
  end
end
