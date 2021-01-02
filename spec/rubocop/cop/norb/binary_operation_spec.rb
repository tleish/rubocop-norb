# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::BinaryOperation, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'offense' do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(code)
      expect(cop.messages).to eq(
        ['This comparison operator logic is not allowed here.']
      )
    end
  end

  shared_examples 'accepts' do |name, code|
    it "accepts usages of #{name}" do
      inspect_source(code)
      expect(cop.offenses.empty?).to be(true)
    end
  end

  it_behaves_like 'accepts', 'and', <<-RUBY
    test = 0
  RUBY


  it_behaves_like 'accepts', ':[]=', <<-RUBY
    flash[:notice] = I18n.t('my.string')
  RUBY

  it_behaves_like 'accepts', '||=', <<-RUBY
    @var ||= MyClass.new
  RUBY

  # boolean operators: `&&`, `||`
  context 'boolean operators' do
    it_behaves_like 'offense', '||', <<-RUBY
      0 || 0
    RUBY

    it_behaves_like 'offense', 'OR', <<-RUBY
      0 or 0
    RUBY

    it_behaves_like 'offense', '&&', <<-RUBY
      0 && 0
    RUBY

    it_behaves_like 'offense', 'and', <<-RUBY
      0 and 0
    RUBY
  end

  # bitwise operators: `|`, `^`, `&`, `<<`, `>>`;
  context 'bitwise operators' do

    it_behaves_like 'offense', '|', <<-RUBY
      0 | 0
    RUBY

    it_behaves_like 'offense', '^', <<-RUBY
      0 ^ 0
    RUBY

    it_behaves_like 'offense', '&', <<-RUBY
      0 & 0
    RUBY

    it_behaves_like 'offense', '<<', <<-RUBY
      0 << 0
    RUBY

    it_behaves_like 'offense', '>>', <<-RUBY
      0 >> 0
    RUBY
  end

  # comparison operators: `==`, `eql?`, `equal?`, `===`, `=~`, `>`, `>=`, `<`, `<=`, `!`, `not`;
  context 'comparison operators' do

    it_behaves_like 'offense', '==', <<-RUBY
      0 == 0
    RUBY

    it_behaves_like 'offense', '===', <<-RUBY
      0 === 0
    RUBY

    it_behaves_like 'offense', 'eql?', <<-RUBY
      0.eql? 0
    RUBY

    it_behaves_like 'offense', 'eql?', <<-RUBY
      0.equal? 0
    RUBY

    it_behaves_like 'offense', '!=', <<-RUBY
      0 == 0
    RUBY

    it_behaves_like 'offense', '>', <<-RUBY
      0 > 0
    RUBY

    it_behaves_like 'offense', '>=', <<-RUBY
      0 >= 0
    RUBY

    it_behaves_like 'offense', '<', <<-RUBY
      0 < 0
    RUBY

    it_behaves_like 'offense', '<=', <<-RUBY
      0 <= 0
    RUBY

    it_behaves_like 'offense', '<=>', <<-RUBY
      0 <=> 0
    RUBY

    it_behaves_like 'offense', '=~', <<-RUBY
      0 =~ 0
    RUBY

    it_behaves_like 'offense', '!~', <<-RUBY
      0 !~ 0
    RUBY

    it_behaves_like 'offense', '!', <<-RUBY
      !0
    RUBY

    it_behaves_like 'offense', 'not', <<-RUBY
      not(0)
    RUBY
  end
end
