# frozen_string_literal: true

namespace :rpn do
  desc "Apply site setting overrides from config/site_setting_overrides.yml"
  task apply_settings: :environment do
    overrides_path = File.expand_path("../../config/site_setting_overrides.yml", __dir__)

    unless File.exist?(overrides_path)
      puts "No overrides file found at #{overrides_path}"
      next
    end

    overrides = YAML.safe_load_file(overrides_path)

    if overrides.blank?
      puts "No settings defined in site_setting_overrides.yml"
      next
    end

    applied = 0
    skipped = 0
    errors = 0

    overrides.each do |name, value|
      result = SiteSetting.set_and_log(name.to_s, value)
      if result
        puts "  set     #{name} = #{value.inspect}"
        applied += 1
      else
        puts "  skip    #{name} (already #{value.inspect})"
        skipped += 1
      end
    rescue Discourse::InvalidParameters => e
      puts "  error   #{name}: #{e.message}"
      errors += 1
    end

    puts "\nDone: #{applied} applied, #{skipped} already correct, #{errors} errors."
    exit 1 if errors > 0
  end
end
