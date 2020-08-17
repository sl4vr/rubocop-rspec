# frozen_string_literal: true

RSpec.shared_context 'with default AllCops.RSpec.Language config', :config do
  let(:all_cops_config) do
    cfg = { 'TargetRubyVersion' => ruby_version }
    cfg['TargetRailsVersion'] = rails_version if rails_version
    cfg.merge({
                'RSpec' => {
                  'Language' => RuboCop::ConfigLoader
                                  .default_configuration
                                  .for_all_cops.dig('RSpec', 'Language')
                }
              })
  end
end
