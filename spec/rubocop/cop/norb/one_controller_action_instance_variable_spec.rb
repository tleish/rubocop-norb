# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::OneControllerActionInstanceVariable, :config do
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
      expect(cop.messages).to eq(["`#{name}` instantiates more than one @instance variable."])
    end
  end

  context 'when valid controller method constructs' do
    it_behaves_like 'accepts', 'no instance variable', <<-RUBY
    def index; end
    RUBY

    it_behaves_like 'accepts', 'one instance variable', <<-RUBY
    def index
      @instance_one = MyClass.new
    end
    RUBY

    it_behaves_like 'accepts', 'one instance variable declared twice', <<-RUBY
    def index 
      if true
        @instance_one = MyClass.new
      else
        @instance_one = MyClassOther.new      
      end
    end
    RUBY

    # Ignores class methods
    it_behaves_like 'accepts', 'class methods', <<-RUBY
    def self.my_class_method; end
    RUBY

    it_behaves_like 'accepts', 'private methods', <<-RUBY
    private
    def index
      @instance_one = MyClass.new
      @instance_two = MyClassOther.new
    end
    RUBY
  end

  context 'when invalid controller method constructs' do
    it_behaves_like 'offense', 'too_many', <<-RUBY
    def too_many
      @instance_one = MyClass.new
      @instance_two = MyClassOther.new
    end
    RUBY

    it_behaves_like 'offense', 'too_many_with_nesting', <<-RUBY
    def too_many_with_nesting
      @instance1 = MyClass.new
      if bool = true
        @instance2 = MyClassOther.new
      end
    end
    RUBY
  end
end
