# frozen_string_literal: true

module ::DiscourseModifications
  class TopicBumpsController < ::ApplicationController
    requires_plugin PLUGIN_NAME
    requires_login

    def create
      Topics::Bump.call(service_params) do
        on_success do |bump_post:|
          render json: { owner_bump_available_at: bump_post.topic.owner_bump_available_at }
        end
        on_model_not_found(:topic) { raise Discourse::NotFound }
        on_failed_policy(:can_see_topic) { raise Discourse::NotFound }
        on_failed_policy(:can_bump_topic) { raise Discourse::InvalidAccess }
        on_failed_policy(:owner_bump_cooldown_elapsed) do |policy|
          render_json_error(policy.reason, status: 422)
        end
        on_failure { render(json: failed_json, status: 422) }
      end
    end
  end
end
