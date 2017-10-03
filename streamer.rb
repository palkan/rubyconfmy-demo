# frozen_string_literal: true

# rubocop:disable all

require_relative "./app"
require_relative "./twitter_stream"
require_relative "./fake_stream"

threads = []
threads << Thread.new { TwitterStream.run }
threads << Thread.new { FakerStream.run("demo") }

threads.each { |t| t.abort_on_exception = true }

threads.map(&:join)
