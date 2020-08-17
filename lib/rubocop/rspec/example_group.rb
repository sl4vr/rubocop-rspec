# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec example groups
    class ExampleGroup < Concept
      # @!method scope_change?(node)
      #
      #   Detect if the node is an example group or shared example
      #
      #   Selectors which indicate that we should stop searching
      #
      def_node_matcher :scope_change?,
                       block_pattern(
                         '{#rspec_all_shared_groups '\
                         '#rspec_all_example_groups '\
                         '#rspec_all_includes}'
                       )

      def lets
        find_all_in_scope(node, :let?)
      end

      def subjects
        find_all_in_scope(node, :subject?)
      end

      def examples
        find_all_in_scope(node, :example?).map do |node|
          Example.new(node, rspec_language_config)
        end
      end

      def hooks
        find_all_in_scope(node, :hook?).map do |node|
          Hook.new(node, rspec_language_config)
        end
      end

      private

      # Recursively search for predicate within the current scope
      #
      # Searches node and halts when a scope change is detected
      #
      # @param node [RuboCop::AST::Node] node to recursively search
      #
      # @return [Array<RuboCop::AST::Node>] discovered nodes
      def find_all_in_scope(node, predicate)
        node.each_child_node.flat_map do |child|
          find_all(child, predicate)
        end
      end

      def find_all(node, predicate)
        if public_send(predicate, node)
          [node]
        elsif scope_change?(node) || example?(node)
          []
        else
          find_all_in_scope(node, predicate)
        end
      end
    end
  end
end
