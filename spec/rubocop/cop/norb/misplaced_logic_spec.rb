# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::MisplacedLogic, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }
  let(:source) { parse_source('puts var') }

  before do
    allow(source.buffer).to receive(:name).and_return(name)
    _investigate(cop, source)
  end

  context 'with code in app/helpers' do
    let(:name) { 'company/blog/app/helpers/blog_helper.rb' }

    it 'reports an offense' do
      expect(cop.offenses.empty?).to be_falsey
    end
  end
end
