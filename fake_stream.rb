# frozen_string_literal: true

# rubocop:disable all

require "faker"

module FakerStream
  class << self
    INTERVAL = (ENV['INTERVAL'] || 2).to_i

    def stop!
      @stopped = true
    end

    def run
      loop do
        break if @stopped

        sleep(INTERVAL + (INTERVAL / 2.0) * (1 - rand))

        author = Faker::Simpsons.character.downcase.gsub(/\s+/, '_')

        text = Faker::Simpsons.quote

        tags = [1, 2, 3].map { "##{Faker::Hacker.noun}" }.join(" ")

        msg = { text: "@#{author} #{text} #{tags}" }

        ActionCable.server.broadcast "demo", msg
        Anycable.pubsub.broadcast "demo", msg.to_json
      end
    end
  end
end
