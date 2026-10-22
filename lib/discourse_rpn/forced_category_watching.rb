# frozen_string_literal: true

module ::DiscourseRpn
  module ForcedCategoryWatching
    def self.category_ids
      return [] if !SiteSetting.discourse_rpn_enabled

      SiteSetting.locked_min_watch_categories_map.reject(&:zero?)
    end

    def self.locked?(category_id)
      category_ids.include?(category_id.to_i)
    end

    def self.below_floor?(level)
      CategoryUser.watching_levels.exclude?(level.to_i)
    end

    def self.violates?(category_id, level)
      locked?(category_id) && below_floor?(level)
    end

    def self.raise_locked!
      raise Discourse::InvalidAccess.new(
              nil,
              nil,
              custom_message: "discourse_rpn.locked_watch_category",
            )
    end

    def self.enforce(user, category_ids: self.category_ids)
      return if category_ids.empty? || user.nil? || user.staged? || user.id <= 0

      existing_ids = Category.where(id: category_ids).pluck(:id)
      current_levels =
        CategoryUser
          .where(user:, category_id: existing_ids)
          .pluck(:category_id, :notification_level)
          .to_h

      existing_ids.each do |category_id|
        next if !below_floor?(current_levels[category_id])

        CategoryUser.set_notification_level_for_category(
          user,
          CategoryUser.notification_levels[:watching_first_post],
          category_id,
        )
      end
    end
  end
end
