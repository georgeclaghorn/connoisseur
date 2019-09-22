require "test_helper"

class Connoisseur::ClientTest < MiniTest::Test
  def setup
    super

    @comment = CLIENT.comment do |c|
      c.content "Hello, world!"
    end
  end

  def test_check_ham
    stub_request(:post, "https://secret.rest.akismet.com/1.1/comment-check")
      .with(body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "false")

    result = @comment.check
    refute result.spam?
    refute result.discard?
  end

  def test_check_spam
    stub_request(:post, "https://secret.rest.akismet.com/1.1/comment-check")
      .with(body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "true")

    result = @comment.check
    assert result.spam?
    refute result.discard?
  end

  def test_check_egregious_spam
    stub_request(:post, "https://secret.rest.akismet.com/1.1/comment-check")
      .with(body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "true", headers: { "X-Akismet-Pro-Tip" => "discard" })

    result = @comment.check
    assert result.spam?
    assert result.discard?
  end

  def test_check_returning_error_status
    stub_request(:post, "https://secret.rest.akismet.com/1.1/comment-check")
      .with(body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 500, body: "false")

    error = assert_raises Connoisseur::Result::InvalidError do
      @comment.check
    end

    assert_equal 'Expected successful response, got 500', error.message
  end

  def test_check_returning_unexpected_body_without_help
    stub_request(:post, "https://secret.rest.akismet.com/1.1/comment-check")
      .with(body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "invalid")

    error = assert_raises Connoisseur::Result::InvalidError do
      @comment.check
    end

    assert_equal 'Expected boolean response body, got "invalid"', error.message
  end

  def test_check_returning_unexpected_body_with_help
    stub_request(:post, "https://secret.rest.akismet.com/1.1/comment-check")
      .with(body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "invalid", headers: { "X-Akismet-Debug-Help" => "We were unable to parse your blog URI" })

    error = assert_raises Connoisseur::Result::InvalidError do
      @comment.check
    end

    assert_equal 'Expected boolean response body, got "invalid" (We were unable to parse your blog URI)', error.message
  end


  def test_submit_spam
    @comment.spam!

    assert_requested :post, "https://secret.rest.akismet.com/1.1/submit-spam",
      body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" }
  end

  def test_submit_ham
    @comment.ham!

    assert_requested :post, "https://secret.rest.akismet.com/1.1/submit-ham",
      body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" }
  end


  def test_update_to_spam
    @comment.update! spam: true

    assert_requested :post, "https://secret.rest.akismet.com/1.1/submit-spam",
      body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" }
  end

  def test_update_to_ham
    @comment.update! spam: false

    assert_requested :post, "https://secret.rest.akismet.com/1.1/submit-ham",
      body: "comment_content=Hello%2C+world%21", headers: { "User-Agent" => "Connoisseur Tests" }
  end


  def test_verify_key_successfully
    stub_request(:post, "https://rest.akismet.com/1.1/verify-key")
      .with(body: "key=secret&blog=https%3A%2F%2Fexample.com", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "valid")

    assert CLIENT.verify_key_for(blog: "https://example.com")
  end

  def test_verify_key_unsuccessfully
    stub_request(:post, "https://rest.akismet.com/1.1/verify-key")
      .with(body: "key=secret&blog=https%3A%2F%2Fexample.com", headers: { "User-Agent" => "Connoisseur Tests" })
      .to_return(status: 200, body: "invalid")

    refute CLIENT.verify_key_for(blog: "https://example.com")
  end
end
