# frozen_string_literal: true

DiscourseModifications::Engine.routes.draw { post "/topics/:topic_id/bump" => "topic_bumps#create" }

Discourse::Application.routes.draw do
  mount ::DiscourseModifications::Engine, at: "discourse-modifications"
end
