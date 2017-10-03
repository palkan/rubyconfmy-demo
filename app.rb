# frozen_string_literal: true

# rubocop:disable all

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

require "rails"
require "global_id"
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

  config.logger = Logger.new($stdout).tap { |logger| logger.level = :warn }
  Rails.logger = config.logger

  routes.draw do
    root to: "home#index"

    mount ActionCable.server => "/cable"
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :id

    def connect
      self.id = SecureRandom.uuid
      logger.info "Connected: #{id}"
    end

    def disconnect
      logger.info "Disconnected: #{id}"
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

class BenchmarkChannel < ApplicationCable::Channel
  STREAMS = (1..(ENV.fetch('SAMPLES_NUM', 10).to_i)).to_a

  if ENV['ID_STREAM']
    def subscribed
      stream_from id
    end
  else
    def subscribed
      stream_from "all#{STREAMS.sample if ENV['SAMPLED']}"
    end
  end

  def echo(data)
    transmit data
  end

  def broadcast(data)
    if ENV['ID_STREAM']
      ActionCable.server.broadcast id, data
    else
      ActionCable.server.broadcast "all#{STREAMS.sample if ENV['SAMPLED']}", data
    end

    data["action"] = "broadcastResult"
    transmit data
  end
end


class HomeController < ActionController::Base
  prepend_view_path Rails.root.join("views").to_s

  def index
    render layout: false
  end
end
