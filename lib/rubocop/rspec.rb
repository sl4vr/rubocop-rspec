# frozen_string_literal: true

module RuboCop
  # RuboCop RSpec project namespace
  module RSpec
    GEM_ROOT         = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT   = GEM_ROOT.join('config', 'default.yml').freeze
    CONFIG           = YAML.safe_load(CONFIG_DEFAULT.read).freeze
    PROJECT_ROOT     = (defined?(Bundler) ? Bundler.root : Dir.pwd).freeze
    ROOT_CONFIG_FILE = File.join(PROJECT_ROOT, '.rubocop.yml').freeze
    ROOT_CONFIG      = YAML.safe_load(File.read(ROOT_CONFIG_FILE)).freeze

    private_constant(
      :CONFIG_DEFAULT, :GEM_ROOT, :PROJECT_ROOT, :ROOT_CONFIG_FILE
    )
  end
end
