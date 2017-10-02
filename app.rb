# frozen_string_literal: true

# rubocop:disable all

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require "rails"
require "dotenv"

require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"

require "redis"

require "slim-rails"

require "anycable"

Dotenv.load(File.join(__dir__, '.env'))

class TestApp < Rails::Application
  secrets.secret_token    = "secret_token"
  secrets.secret_key_base = "secret_key_base"

  config.public_file_server.enabled = true

  config.logger = Logger.new($stdout).tap { |logger| logger.level = :info }
  Rails.logger = config.logger

  routes.draw do
    root to: "home#index"

    mount ActionCable.server => "/cable"
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      logger.info "Connected"
    end

    def disconnect
      logger.info "Disconnected"
    end
  end
end

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

ActionCable.server.config.logger = Rails.logger
ActionCable.server.config.cable = { "adapter" => "redis" }
ActionCable.server.config.connection_class = -> { ApplicationCable::Connection }
ActionCable.server.config.disable_request_forgery_protection = true

class DemoChannel < ApplicationCable::Channel
  def subscribed
    stream_from "demo"
  end
end

class IdleChannel < ApplicationCable::Channel
  def subscribed
  end
end

class HomeController < ActionController::Base
  prepend_view_path Rails.root.join("views").to_s

  def index
    render layout: false
  end
end
