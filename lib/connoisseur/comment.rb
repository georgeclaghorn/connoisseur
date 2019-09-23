class Connoisseur::Comment
  attr_reader :parameters

  # Internal: Define a comment via a DSL.
  #
  # service - A Connoisseur::Service for issuing API requests.
  #
  # Yields a Comment::Definition for declaring the comment's attributes.
  #
  # Returns a Connoisseur::Comment.
  def self.define(service, &block)
    new service, Definition.build(&block).parameters
  end

  # Internal: Initialize a Connoisseur::Comment.
  #
  # service    - A Connoisseur::Service for issuing API requests.
  # parameters - A Hash of POST parameters describing the comment for use in API requests.
  def initialize(service, parameters)
    @service, @parameters = service, parameters
  end

  # Public: Determine whether a comment is spam or ham.
  #
  # Examples
  #
  #   result = comment.check
  #   result.spam?
  #   result.valid?
  #
  # Returns a Connoisseur::Result.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  # Raises Connoisseur::UnexpectedResponse if the Akismet API responds unexpectedly.
  def check
    @service.check(@parameters)
  end

  # Public: Inform Akismet that the comment should have been marked spam.
  #
  # Returns nothing.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  def spam!
    @service.spam!(@parameters)
  end

  # Public: Inform Akismet that the comment should have been marked ham.
  #
  # Returns nothing.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  def ham!
    @service.ham!(@parameters)
  end

  # Public: Inform Akismet that it incorrectly classified the comment.
  #
  # spam - A boolean indicating whether the comment should have been marked spam.
  #
  # Returns nothing.
  # Raises Connoisseur::Timeout if the HTTP request to the Akismet API times out.
  def update!(spam:)
    if spam
      spam!
    else
      ham!
    end
  end
end

require "connoisseur/comment/definition"
