# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::ActiveRecordNamespaced, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      { 'AllCops' => { 'Include' => [] }, described_class.badge.to_s => cop_config },
      '/some/.rubocop.yml'
    )
  end

  let(:cop_config) do
    {
      'ActiveRecordNamespace' => 'Ar',
      'ActiveRecordSuperclasses' => %w[ActiveRecord ApplicationRecord]
    }
  end

  let(:msg) { ['ActiveRecord classes must be namespaced with Ar.'] }

  shared_examples 'accepts' do |name, code|
    it "accepts usages of #{name}" do
      inspect_source(code)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples 'offense' do |name, code|
    it "registers an offense for #{name}" do
      inspect_source(code)
      expect(cop.messages).to eq(msg)
    end
  end

  context 'with Ar as namespace' do
    it_behaves_like 'offense', 'when Ar is not used for ActiveRecord', <<-RUBY
      module RootModule
        class Article < ActiveRecord; end
      end
    RUBY

    it_behaves_like 'offense', 'when Ar is not used for ActiveRecord::Base', <<-RUBY
    module Blog
      module Author
        class Article < ActiveRecord::Base
          def my_method; end
        end
      end
    end
    RUBY

    it_behaves_like 'offense', 'when Ar namespace is not used for ApplicationRecord', <<-RUBY
    module RootModule
      class Article < ApplicationRecord; end
    end
    RUBY

    it_behaves_like 'offense', 'when class has :: in namespace', <<-RUBY
    module RootModule
      class Article::Comment < ActiveRecord::Base; end
    end
    RUBY

    it_behaves_like 'accepts', 'Nested Ar namespace is used for ActiveRecord::Base', <<-RUBY
    module Ar
      module Email
        class Article < ActiveRecord::Base; end
      end
    end
    RUBY

    it_behaves_like 'accepts', 'when Ar namespace is used for ApplicationRecord', <<-RUBY
    module Ar
      class Article < ApplicationRecord; end
    end
    RUBY

    it_behaves_like 'accepts', 'when ActiveRecord::Base is used inside def of class', <<-RUBY
    module RootModule
      class Article
        def execute(sql)
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
    RUBY

    it_behaves_like 'accepts', 'when Ar and class has :: in namespace', <<-RUBY
    module Ar
      class Article::Comment < ActiveRecord::Base; end
    end
    RUBY

    it_behaves_like 'accepts', 'when class has :: in namespace', <<-RUBY
      module RootModule
        class Article::Comment
          def execute(sql)
            ActiveRecord::Base.connection.execute(sql)
          end
        end
      end
    RUBY
  end

  context 'when custom namespace and ar class' do
    shared_examples 'custom namespace offense' do |name, code|
      let(:code) { code }
      let(:msg) { ['ActiveRecord classes must be namespaced with AcmeNamespace.'] }
      let(:cop_config) do
        {
          'ActiveRecordNamespace' => 'AcmeNamespace',
          'ActiveRecordSuperclasses' => %w[ActiveBlueprint]
        }
      end

      it "registers an offense for #{name}" do
        inspect_source(code)
        expect(cop.messages).to eq(msg)
      end
    end

    it_behaves_like 'custom namespace offense', 'when customer namespace is not used', <<-RUBY
        module RootModule
          class Article < ActiveBlueprint; end
        end
    RUBY
  end
end
