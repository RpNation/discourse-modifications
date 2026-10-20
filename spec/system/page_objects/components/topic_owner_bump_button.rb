# frozen_string_literal: true

module PageObjects
  module Components
    class TopicOwnerBumpButton < PageObjects::Components::Base
      SELECTOR = "#topic-footer-buttons #topic-footer-button-topic-owner-bump"

      def click
        find(SELECTOR).click
        self
      end

      def disabled?
        has_css?("#{SELECTOR}[disabled]")
      end

      def enabled?
        has_css?("#{SELECTOR}:not([disabled])")
      end

      def has_countdown?
        has_css?(SELECTOR, text: /Bump in \d/)
      end
    end
  end
end
