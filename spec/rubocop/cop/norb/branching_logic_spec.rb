# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Norb::BranchingLogic, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'offense' do |name, code|
    let(:code) { code }

    it "registers an offense for #{name}" do
      inspect_source(code)
      expect(cop.messages).to eq(
        ['This branching logic is not allowed here.']
      )
    end
  end

  context 'when multiline branch' do
    it_behaves_like 'offense', 'if', <<-RUBY
      if true
        my_var = 1
      else
        my_var = 2
      end
    RUBY

    it_behaves_like 'offense', 'unless', <<-RUBY
      unless true
        my_var = 1
      else
        my_var = 2
      end
    RUBY

    it_behaves_like 'offense', 'case', <<-RUBY
      case expr0
      when expr1, expr2
         stmt1
      when expr3, expr4
         stmt2
      else
         stmt3
      end
    RUBY

    it_behaves_like 'offense', 'rescue block', <<-RUBY
      begin
        my_method
      rescue
        raise
      end
    RUBY
  end

  context 'when single line branch' do
    it_behaves_like 'offense', 'if', <<-RUBY
      my_var = 1 if true
    RUBY

    it_behaves_like 'offense', 'unless', <<-RUBY
      my_var = 1 unless true
    RUBY

    it_behaves_like 'offense', 'ternary', <<-RUBY
      my_var = true ? 1 : 0
    RUBY

    it_behaves_like 'offense', '||', <<-RUBY
      my_var = false || true
    RUBY

    it_behaves_like 'offense', 'OR', <<-RUBY
      my_var = false or true
    RUBY

    it_behaves_like 'offense', '&&', <<-RUBY
      my_var = false && true
    RUBY

    it_behaves_like 'offense', 'and', <<-RUBY
      my_var = false and true
    RUBY

    it_behaves_like 'offense', 'rescue', <<-RUBY
      user.destroy! rescue nil
    RUBY
  end
end
