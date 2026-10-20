# frozen_string_literal: true

class RenameDiscourseModificationsEnabledSetting < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE site_settings SET name = 'discourse_rpn_enabled' WHERE name = 'discourse_modifications_enabled'"
  end

  def down
    execute "UPDATE site_settings SET name = 'discourse_modifications_enabled' WHERE name = 'discourse_rpn_enabled'"
  end
end
