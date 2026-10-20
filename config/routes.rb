# frozen_string_literal: true

DiscourseRpn::Engine.routes.draw { post "/topics/:topic_id/bump" => "topic_bumps#create" }

Discourse::Application.routes.draw { mount ::DiscourseRpn::Engine, at: "discourse-rpn" }
