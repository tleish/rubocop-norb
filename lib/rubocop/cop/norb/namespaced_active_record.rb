# frozen_string_literal: true

require 'forwardable'

module RuboCop
  module Cop
    module Norb
      # This cop checks to see if an ActiveRecord model is namespaced.
      # Namespacing ActiveRecord models (e.g. Ar::) allows ActiveRecord to be
      # separated from business logic, without conflicting names.
      #
      # @example
      #   # bad
      #   # app/models/user.rb
      #   class User < ActiveRecord::Base
      #   end
      #
      #
      #   # good
      #   # app/models/ar/user.rb
      #   module Ar
      #     class User < ActiveRecord::Base
      #       self.table_name = 'user'
      #     end
      #   end
      #
      #
      #   # good
      #   # app/models/ar.rb
      #   module Ar
      #     # remove the auto 'ar_' prefix from namespaced Ar::Model(s)
      #     def self.table_name_prefix
      #       ''
      #     end
      #   end
      #
      #   # app/models/ar/user.rb
      #   module Ar
      #     class User < ActiveRecord::Base
      #     end
      #   end
      #
      class NamespacedActiveRecord < Cop
        CONFIGS = {
          namespace: OpenStruct.new(key: 'ActiveRecordNamespace', default: :Ar),
          superclasses: OpenStruct.new(
            key: 'ActiveRecordSuperclasses',
            default: %i[ActiveRecord ApplicationRecord]
          )
        }.freeze

        def on_class(node)
          sub_cop = CLASS_TYPES.map do |active_record_class_type|
            active_record_class_type.new(cop: self, node: node)
          end.find(&:valid?)
          sub_cop.add_offense
        end

        # ActiveRecord Detection Class
        class ActiveRecordClassType
          extend NodePattern::Macros
          extend Forwardable
          MSG = 'ActiveRecord classes must be namespaced with %<namespace>s.'

          attr_reader :cop, :node

          def_node_search :constants, <<-PATTERN
            (const _ $_name)
          PATTERN

          def_delegators :@cop_config, :active_record_superclass, :active_record_namespace

          def initialize(cop:, node:)
            @cop = cop
            @cop_config = CopConfig.for(cop.cop_config)
            @node = node
          end

          def valid?
            active_record? && invalid_namespace?
          end

          def add_offense
            cop.add_offense(@node, message: message) if valid?
          end

          private

          def parent_constants
            @parent_constants ||= parent_nodes.flat_map do |node_id|
              constants(node_id.identifier).to_a
            end.uniq
          end

          def superclass_constants
            return [] unless node.parent_class
            constants(node.parent_class).to_a
          end

          def parent_nodes
            nodes = []
            node.ancestors.last.each_node(:class, :module) do |child_node|
              break if child_node == node
              nodes << child_node
            end
            nodes
          end

          def active_record?
            superclass_constants.any? { |constant| active_record_superclass.include?(constant) }
          end

          def invalid_namespace?
            parent_constants.none? { |constant| constant == active_record_namespace }
          end

          def message
            format(MSG, namespace: active_record_namespace)
          end
        end

        # Null CLass Type for ActiveRecord Classes
        class NilType < ActiveRecordClassType
          def valid?
            true
          end

          def add_offense; end
        end

        CLASS_TYPES = [ActiveRecordClassType, NilType].freeze

        # Refinement to get cop configuration from symbol
        module SymbolToConfigParamRefinement
          refine Symbol do
            def value_in(cop_config)
              configs = Norb::NamespacedActiveRecord::CONFIGS
              value = yield(cop_config[configs[self].key])
              if value.empty?
                configs[self].default
              else
                value
              end
            end
          end
        end
        using SymbolToConfigParamRefinement

        # Cop Configuration wrapper to add namespace and superclass configurations
        class CopConfig
          def self.for(cop_config = {})
            namespace = :namespace.value_in(cop_config) do |value|
              value.to_s.to_sym
            end

            superclasses = :superclasses.value_in(cop_config) do |value|
              value.to_a.map(&:to_sym)
            end

            new(namespace: namespace, superclasses: superclasses)
          end

          attr_reader :active_record_namespace, :active_record_superclass
          def initialize(namespace:, superclasses:)
            @active_record_namespace = namespace
            @active_record_superclass = superclasses
          end
        end
      end
    end
  end
end
