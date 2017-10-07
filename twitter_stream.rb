# frozen_string_literal: true

# rubocop:disable all

require "twitter"

module TwitterStream
  class << self
    def config
      {
        consumer_key:        ENV['TWITTER_CONSUMER_KEY'],
        consumer_secret:     ENV['TWITTER_CONSUMER_SECRET'],
        access_token:        ENV['TWITTER_ACCESS_TOKEN'],
        access_token_secret: ENV['TWITTER_ACCESS_TOKEN_SECRET']
      }
    end

    def client
      @client ||= Twitter::Streaming::Client.new(config)
    end

    def run
      client.filter(track: "rubyconfmy,rubyconf,rails,websockets") do |tweet|
        ActionCable.server.broadcast "demo", text: tweet.text
        Anycable.pubsub.broadcast "demo",  { text: tweet.text }.to_json
      end
    end
  end
end
