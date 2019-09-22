require "bundler/setup"

require "minitest/autorun"
require "webmock/minitest"
require "byebug"

require "connoisseur"

CLIENT = Connoisseur::Client.new(key: "secret", user_agent: "Connoisseur Tests")

class MiniTest::Test
  def setup
    stub_request :any, /.*/
  end
end
