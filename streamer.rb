# frozen_string_literal: true

# rubocop:disable all

require_relative "./app"
require_relative "./twitter_stream"
require_relative "./fake_stream"

tw_thread = Thread.new { TwitterStream.run }
tw_thread.abort_on_exception = true

fake_thread = Thread.new { FakerStream.run }
fake_thread.abort_on_exception = true

[tw_thread, fake_thread].map(&:join)
