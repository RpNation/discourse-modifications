# frozen_string_literal: true

module ::DiscourseRpn
  module UsersControllerExtension
    extend ActiveSupport::Concern

    included { before_action :ensure_category_preferences_not_locked, only: :update }

    private

    def ensure_category_preferences_not_locked
      locked_ids = ForcedCategoryWatching.category_ids
      return if locked_ids.empty?

      requested_ids = lowering_category_params.flat_map { |key| Array(params[key]).map(&:to_i) }
      ForcedCategoryWatching.raise_locked! if requested_ids.intersect?(locked_ids)
    end

    def lowering_category_params
      UserUpdater::CATEGORY_IDS.filter_map do |param, level|
        param if ForcedCategoryWatching.below_floor?(CategoryUser.notification_levels[level])
      end
    end
  end
end
