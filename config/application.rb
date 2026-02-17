require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Portal
  class Application < Rails::Application
    config.load_defaults 7.0 # ή 8.0 ανάλογα την έκδοσή σου
    config.time_zone = 'Athens'
    config.active_record.default_timezone = :local

    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'local_env.yml')
      if File.exist?(env_file)
        config_vars = YAML.load(File.open(env_file))
        # Ελέγχουμε αν είναι όντως πίνακας πριν κάνουμε each
        if config_vars.is_a?(Hash)
          config_vars.each do |key, value|
            ENV[key.to_s] = value.to_s
          end
        end
      end
    end

  end
end