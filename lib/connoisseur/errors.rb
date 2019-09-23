module Connoisseur
  # Public: Base class for all client errors.
  class Error < StandardError
  end

  # Public: Raised when a request to Akismet encounters a timeout.
  class Timeout < Error
  end

  # Public: Raised when Akismet responds with an error status code or an invalid body.
  class UnexpectedResponse < Error
  end
end
