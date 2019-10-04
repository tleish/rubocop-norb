# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::ActiveRecordThroughBusiness, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(RuboCop::Cop::Norb::NamespacedActiveRecord.badge.to_s => cop_config)
  end

  let(:cop_config) { { 'ActiveRecordNamespace' => 'Ar' } }

  shared_examples 'accepts' do |name, code|
    it "accepts usages of #{name}" do
      inspect_source(code)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  shared_examples 'offense' do |name, code|
    it "registers an offense for #{name}" do
      inspect_source(code)
      expect(cop.messages).to eq(['Direct ActiveRecord calls should come from business objects.'])
    end
  end

  context 'with Ar as namespace ' do
    it_behaves_like 'offense', 'is used', <<-RUBY
      Ar::Article.new
    RUBY

    it_behaves_like 'offense', 'is used and assigned to variable', <<-RUBY
      article = Ar::Article.new
    RUBY

    it_behaves_like 'offense', 'nested inside another namespace', <<-RUBY
      MyCustomNamespace::Ar::Article.new
    RUBY

    it_behaves_like 'accepts', 'but class with any other namespace is called', <<-RUBY
      user = Article::Comments.new
    RUBY
  end

  context 'with custom namespace ' do
    let(:cop_config) { { 'ActiveRecordNamespace' => 'MyCustomNamespace' } }

    it_behaves_like 'accepts', 'Ar is used', <<-RUBY
      Ar::Article.new
    RUBY

    it_behaves_like 'offense', 'custom namespaces', <<-RUBY
      MyCustomNamespace::Article.new
    RUBY
  end
end
