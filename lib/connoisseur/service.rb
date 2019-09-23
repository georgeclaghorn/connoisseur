# frozen_string_literal: true

require "connoisseur/result"
require "connoisseur/errors"

class Connoisseur::Service
  # Internal: Initialize a Connoisseur service.
  #
  # key        - An Akismet API key, obtained from https://akismet.com.
  # user_agent - The String value to provide in the User-Agent header when issuing
  #              HTTP requests to the Akismet API.
  #
  # Raises ArgumentError if the key is nil or blank.
  def initialize(key:, user_agent:)
    @key, @user_agent = key, user_agent

    require_usable_key
  end

  # Internal: Determine whether a comment is spam or ham.
  #
  # comment - A Hash of POST parameters describing the comment.
  #
  # Returns a Connoisseur::Result.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  # Raises Connoisseur::UnexpectedResponse if the Akismet API responds with an
  #   error status code or invalid body.
  def check(comment)
    Connoisseur::Result.new(post("comment-check", body: comment)).validated
  end

  # Internal: Inform Akismet that a comment should have been marked spam.
  #
  # comment - A Hash of POST parameters describing the comment.
  #
  # Returns nothing.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  def spam!(comment)
    post "submit-spam", body: comment
  end

  # Internal: Inform Akismet that a comment should have been marked ham.
  #
  # comment - A Hash of POST parameters describing the comment.
  #
  # Returns nothing.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  def ham!(comment)
    post "submit-ham", body: comment
  end

  # Internal: Verify the service's Akismet API key.
  #
  # blog - The URL of the blog associated with the key.
  #
  # Returns true or false indicating whether the key is valid for the given blog.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  def verify_key_for(blog:)
    post_without_subdomain("verify-key", body: { key: key, blog: blog }).body == "valid"
  end

  private

  attr_reader :key, :user_agent

  def require_usable_key
    raise ArgumentError, "Expected Akismet API key, got #{key.inspect}" if !key || key =~ /\A[[:space:]]*\z/
  end


  def post(endpoint, body:)
    handle_network_errors do
      Net::HTTP.post \
        URI("https://#{key}.rest.akismet.com/1.1/#{endpoint}"), URI.encode_www_form(body), headers
    end
  end

  def post_without_subdomain(endpoint, body:)
    handle_network_errors do
      Net::HTTP.post \
        URI("https://rest.akismet.com/1.1/#{endpoint}"), URI.encode_www_form(body), headers
    end
  end

  def handle_network_errors
    yield
  rescue Net::OpenTimeout
    raise Connoisseur::Timeout, "Timed out opening connection to Akismet"
  rescue Net::ReadTimeout
    raise Connoisseur::Timeout, "Timed out reading response from Akismet"
  end

  def headers
    { "User-Agent" => user_agent }
  end
end
