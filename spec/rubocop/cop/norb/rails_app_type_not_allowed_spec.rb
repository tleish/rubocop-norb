# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::RailsAppTypeNotAllowed do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
    { 'AllCops' => { 'Include' => includes },
      described_class.badge.to_s => cop_config },
    '/some/.rubocop.yml'
    )
  end
  let(:cop_config) do
    {
    'IgnoreExecutableScripts' => true,
    'ExpectMatchingDefinition' => false,
    'Regex' => nil
    }
  end

  let(:includes) { ['**/*.rb'] }
  let(:source) { 'print 1' }
  let(:processed_source) { parse_source(source) }
  let(:offenses) { _investigate(cop, processed_source) }
  let(:messages) { offenses.sort.map(&:message) }

  before do
    allow(processed_source.buffer).to receive(:name).and_return(filename)
  end

  context 'with files in the rails_blog/app/helpers' do
    let(:filename) { 'rails_blog/app/helpers/foo.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with namespaced files in the rails_blog/app/helpers' do
    let(:filename) { 'rails_blog/app/helpers/my_namespace/foo.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with files in the rails_blog/app/services' do
    let(:filename) { 'rails_blog/app/services/foo.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with files in the rails_blog/app/decorators' do
    let(:filename) { 'rails_blog/app/decorators/foo.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with files in the rails_blog/app/policies' do
    let(:filename) { 'rails_blog/app/policies/foo.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
    end
  end

  context 'with files in the rails_blog/app/support' do
    let(:filename) { 'rails_blog/app/support/foo.rb' }

    it 'reports an offense' do
      expect(offenses.size).to eq(1)
      expect(messages).to eq(['This Rails app/support type is not allowed.'])
    end
  end
end
