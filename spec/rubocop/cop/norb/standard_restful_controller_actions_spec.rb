# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::StandardRestfulControllerActions, :config do
  subject(:cop) { described_class.new(config) }

  let(:source) do
    <<-RUBY
      module Blog
        class PostController < ApplicationController      
          #{code}
        end
      end
    RUBY
  end

  shared_examples 'accepts' do |name, code|
    let(:code) { code }

    it "accepts usages of #{name}" do
      inspect_source(source)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples 'offense' do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(source)
      expect(cop.messages).to eq(["`#{name}` is not a standard RESTful controller action."])
    end
  end

  context 'when valid controller method constucts' do
    it_behaves_like 'accepts', 'standard Rails RESTFul actions', <<-RUBY
      def index; end          
      def show; end
      def new; end
      def edit; end
      def create; end
      def update; end
      def destroy; end
    RUBY

    # Ignores class methods
    it_behaves_like 'accepts', 'class methods', <<-RUBY
      def self.my_class_method; end
    RUBY

    it_behaves_like 'accepts', 'private methods', <<-RUBY
      private
      def my_private_method; end
    RUBY
  end

  context 'when invalid controller method constucts' do
    it_behaves_like 'offense', 'ajax_products', <<-RUBY
      def index; end          
      def show; end
      def new; end
      def edit; end
      def create; end
      def update; end
      def destroy; end      

      def ajax_products; end
    RUBY
  end
end
