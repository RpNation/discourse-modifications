# frozen_string_literal: true

module ::DiscourseRpn
  module CategoriesControllerExtension
    extend ActiveSupport::Concern

    included { before_action :ensure_notification_level_not_locked, only: :set_notifications }

    private

    def ensure_notification_level_not_locked
      return if !current_user

      if ForcedCategoryWatching.violates?(params[:category_id], params[:notification_level])
        ForcedCategoryWatching.raise_locked!
      end
    end
  end
end
