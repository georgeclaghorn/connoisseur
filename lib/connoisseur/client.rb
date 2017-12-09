require "connoisseur/service"
require "connoisseur/comment"

class Connoisseur::Client
  # Public: Build a Connoisseur client.
  #
  # key        - Your Akismet API key, obtained from https://akismet.com.
  #              Defaults to Connoisseur.key.
  # user_agent - The String value to provide in the User-Agent header when issuing
  #              HTTP requests to the Akismet API. Defaults to Connoisseur.user_agent.
  #
  # Raises ArgumentError if the key is nil or blank.
  # Returns a Connoisseur::Client.
  def self.build(key: Connoisseur.key, user_agent: Connoisseur.user_agent)
    Connoisseur::Client.new \
      Connoisseur::Service.new(key: key, user_agent: user_agent)
  end

  # Internal: Initialize a Connoisseur client.
  #
  # service - A Connoisseur::Service for issuing API requests.
  def initialize(service)
    @service = service
  end

  # Public: Build a comment.
  #
  # Yields a Connoisseur::Comment::Definition for declaring the comment's attributes.
  #
  # Examples
  #
  #   client.comment do |c|
  #     c.blog url: "https://example.com"
  #     c.post url: "https://example.com/posts/hello-world"
  #     c.author name: "Jane Smith"
  #     c.content "Nice post!"
  #   end
  #   # => #<Connoisseur::Comment ...>
  #
  # Returns a Connoisseur::Comment.
  def comment(&block)
    Connoisseur::Comment.define(@service, &block)
  end

  # Public: Verify the client's Akismet API key.
  #
  # blog - The URL of the blog associated with the key.
  #
  # Returns true or false indicating whether the key is valid for the given blog.
  def verify_key_for(blog:)
    @service.verify_key_for(blog: blog)
  end
end
