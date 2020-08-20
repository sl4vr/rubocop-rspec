# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::EmptyExampleGroup do
  it 'flags an empty example group' do
    expect_offense(<<~RUBY)
      describe Foo do
        context 'when bar' do
        ^^^^^^^^^^^^^^^^^^ Empty example group detected.

          let(:foo) { bar }
        end

        describe '#thingy?' do
          specify do
            expect(whatever.thingy?).to be(true)
          end
        end

        it { should be_true }
      end
    RUBY
  end

  it 'flags an empty top level describe' do
    expect_offense(<<~RUBY)
      describe Foo do
      ^^^^^^^^^^^^ Empty example group detected.
      end
    RUBY
  end

  it 'flags example group with examples defined in hooks' do
    expect_offense(<<~RUBY)
      context 'hook with implicit scope' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
        before do
          it { is_expected.to never_run }
        end
      end

      context 'hook with explicit scope' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
        around(:example) do
          it { is_expected.to never_run }
        end
      end

      context 'hook with explicit scope and metadata' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
        after(:each, :corrupt, type: :cop) do
          it { is_expected.to never_run }
        end
      end
    RUBY
  end

  it 'ignores example group with examples defined in iterator' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop monthly' do
        [1, 2, 3].each do |page|
          it { expect(newspaper(page)).to have_ads }
        end
      end
    RUBY
  end

  it 'ignores example group with examples defined in an iterator' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop weekly' do
        some_method
        [1, 2, 3].each do |page|
          it { expect(newspaper(page)).to have_ads }
        end
        more_surroundings
      end
    RUBY
  end

  it 'flags example group with no examples defined in an iterator' do
    expect_offense(<<~RUBY)
      describe 'RuboCop Sunday' do
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
        some_method
        [1, 2, 3].each do |page|
          no_examples_here
          and_no_ads_either
        end
        more_surroundings
      end
    RUBY
  end

  it 'ignores example group with examples defined in an custom block' do
    expect_no_offenses(<<~RUBY)
      context 'without arguments' do
        mute_warnings do
          it { expect(newspaper(page)).to have_a_lot_of_ads }
        end
      end

      context 'with an argument' do
        with_role :reader do
          it { expect(newspaper(page)).to have_a_lot_of_ads }
        end
      end

      context 'with a block argument' do
        for_all_species_coming_from(:fish) do |creature|
          it { expect(newspaper(page)).to have_a_lot_of_ads }
        end
      end
    RUBY
  end

  it 'ignores example group with examples defined in an obscure iterators' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop Friday night' do
        context 'with each.with_object' do
          [1, 2, 3].each.with_object(0) do |page, price|
            it { expect(newspaper(page)).to have_ads }
          end
        end

        context 'with each_with_index' do
          [1, 2, 3].each_with_index do |page, index|
            it { expect(newspaper(page)).to have_ads }
          end
        end

        context 'with map' do
          [1, 2, 3].map do |page, index|
            it { expect(newspaper(page)).to have_ads }
          end
        end

        context 'with count' do
          [1, 2, 3].count do |page, index|
            it { expect(newspaper(page)).to have_ads }
          end
        end
      end
    RUBY
  end

  it 'ignores example group with examples defined in a nested iterator' do
    expect_no_offenses(<<~RUBY)
      describe 'RuboCop daily' do
        some_method
        [1, 2, 3].each do |page|
          some_method
          [1, 2, 3].each do |paragraph|
            it { expect(newspaper(page, paragraph)).to have_ads }
          end
          more_surroundings
        end
        more_surroundings
      end
    RUBY
  end

  it 'ignores examples groups with includes' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        context "when something is true" do
          include_examples "some expectations"
        end

        context "when something else is true" do
          include_context "some expectations"
        end

        context "when the third thing is true" do
          it_behaves_like "some thingy"
        end

        context "when the fourth thing is true" do
          it_behaves_like "some thingy" do
            let(:a) { 'foo' }
          end
        end

        context "when the fifth thing is true" do
          it_behaves_like "some thingy", &block
        end
      end
    RUBY
  end

  it 'ignores methods matching example group names' do
    expect_no_offenses(<<~RUBY)
      describe Foo do
        it 'yields a block when given' do
          value = nil

          helper.feature('whatevs') { value = 5 }

          expect(value).to be 5
        end
      end
    RUBY
  end

  it 'flags custom include methods by default' do
    expect_offense(<<~RUBY)
      describe Foo do
        context "when I do something clever" do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Empty example group detected.
          it_has_special_behavior
        end
      end
    RUBY
  end

  context 'when a custom include method is specified' do
    let(:cop_config) do
      { 'CustomIncludeMethods' => %w[it_has_special_behavior] }
    end

    it 'ignores an empty example group with a custom include' do
      expect_no_offenses(<<~RUBY)
        describe Foo do
          context "when I do something clever" do
            it_has_special_behavior
          end
        end
      RUBY
    end
  end
end
