# frozen_string_literal: true

module RuboCop
  module RSpec
    # Aliases for rspec DSL configuration in root .rubocop.yml file
    class AliasConfig < Config
      project_root = defined?(Bundler) ? Bundler.root : Dir.pwd
      root_config_file = ConfigLoader.configuration_file_for(project_root)

      CONFIG = AliasConfig.new(
        YAML.safe_load(File.read(root_config_file)),
        root_config_file
      )

      def aliases_for(*sections)
        aliases = aliases_config.dig(*sections) || []
        aliases.map(&:to_sym)
      end

      private

      def aliases_config
        for_all_cops
          .fetch('RSpec', {})
          .fetch('Aliases', {})
      end
    end
  end
end
