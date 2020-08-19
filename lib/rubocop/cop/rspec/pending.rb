# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # Checks for any pending or skipped examples.
      #
      # @example
      #   # bad
      #   describe MyClass do
      #     it "should be true"
      #   end
      #
      #   describe MyClass do
      #     it "should be true", skip: true do
      #       expect(1).to eq(2)
      #     end
      #   end
      #
      #   describe MyClass do
      #     it "should be true" do
      #       pending
      #     end
      #   end
      #
      #   describe MyClass do
      #     xit "should be true" do
      #     end
      #   end
      #
      #   # good
      #   describe MyClass do
      #   end
      class Pending < Base
        MSG = 'Pending spec found.'

        def_node_matcher :skippable?,
                         send_pattern(
                           '{#rspec(:ExampleGroups, :Regular) '\
                           '#rspec(:Examples, :Regular)}'
                         )

        def_node_matcher :skipped_in_metadata?, <<-PATTERN
          {
            (send _ _ <#skip_or_pending? ...>)
            (send _ _ ... (hash <(pair #skip_or_pending? { true str }) ...>))
          }
        PATTERN

        def_node_matcher :skip_or_pending?, '{(sym :skip) (sym :pending)}'

        def_node_matcher :pending_block?,
                         send_pattern(
                           '{#rspec(:ExampleGroups, :Skipped) '\
                           '#rspec(:Examples, :Skipped) '\
                           '#rspec(:Examples, :Pending)}'
                         )

        def on_send(node)
          return unless pending_block?(node) || skipped?(node)

          add_offense(node)
        end

        private

        def skipped?(node)
          skippable?(node) && skipped_in_metadata?(node)
        end
      end
    end
  end
end
