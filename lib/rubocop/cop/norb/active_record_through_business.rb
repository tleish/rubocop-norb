# frozen_string_literal: true

module RuboCop
  module Cop
    module Norb
      # This cop checks to see if ActiveRecord namespace is being called non-business objects.
      # Separation of controllers, views, jobs and other node objects should go through
      # business logic in order to separate direct access to databases.
      #
      # Note: namespace config from `Norb/ActiveRecordNamespaced` settings
      #
      # @example
      #   # bad
      #   # app/controllers/article_controller.rb
      #   class ArticleController < ApplicationController
      #     def show
      #       Ar::Article.find(params[:id])
      #     end
      #   end
      #
      #   # good
      #   # app/controllers/article_controller.rb
      #   class ArticleController < ApplicationController
      #     def show
      #       Article.for(params[:id])
      #     end
      #   end
      #
      #   # app/models/article.rb
      #   class Article
      #     def self.for(id)
      #       Ar::Article.find(id)
      #     end
      #   end
      #
      class ActiveRecordThroughBusiness < Cop
        MSG = 'Direct ActiveRecord calls should come from business objects.'

        def_node_matcher :const_name, <<-PATTERN
          (... $_const_name)
        PATTERN

        def on_const(node)
          add_offense(node) if const_name(node) == namespace.to_sym
        end

        private

        # Get namespace from the Norb::ActiveRecordNamespaced class
        def namespace
          namespace_class = RuboCop::Cop::Norb::ActiveRecordNamespaced
          @namespace ||= @config.for_cop(namespace_class.department.to_s)
                                .merge(@config.for_cop(namespace_class))
                                .fetch(namespace_class::CONFIGS[:namespace].key)
        end
      end
    end
  end
end
