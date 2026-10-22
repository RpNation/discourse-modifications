# frozen_string_literal: true

module ::DiscourseRpn
  module CategoryUserExtension
    extend ActiveSupport::Concern

    module Overrides
      def batch_set(user, level, category_ids)
        changed = super
        ForcedCategoryWatching.enforce(user)
        changed
      end
    end

    included do
      singleton_class.prepend(Overrides)

      before_destroy :prevent_destroying_locked_watch
    end

    private

    # Destroys cascading from a deleted user or category must still go through.
    def prevent_destroying_locked_watch
      throw :abort if !destroyed_by_association && ForcedCategoryWatching.locked?(category_id)
    end
  end
end
