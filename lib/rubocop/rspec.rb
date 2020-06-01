# frozen_string_literal: true

module RuboCop
  # RuboCop RSpec project namespace
  module RSpec
    GEM_ROOT         = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT   = GEM_ROOT.join('config', 'default.yml').freeze
    CONFIG           = YAML.safe_load(CONFIG_DEFAULT.read).freeze
    PROJECT_ROOT     = (defined?(Bundler) ? Bundler.root : Dir.pwd).freeze
    RSPEC_CONFIG_FILE = File.join(PROJECT_ROOT, '.rubocop-rspec.yml').freeze

    # Create default rspec config in project root if absent
    unless File.exists?(RSPEC_CONFIG_FILE)
      FileUtils.cp(
        GEM_ROOT.join('config', '.rubocop-rspec.yml'),
        RSPEC_CONFIG_FILE
      )
    end

    RSPEC_CONFIG = YAML.safe_load(File.read(RSPEC_CONFIG_FILE)).freeze

    private_constant(
      :CONFIG_DEFAULT, :GEM_ROOT, :PROJECT_ROOT, :RSPEC_CONFIG_FILE
    )
  end
end
