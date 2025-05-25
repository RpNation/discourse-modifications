# frozen_string_literal: true

DiscourseModifications::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DiscourseModifications::Engine, at: "discourse-modifications" }
