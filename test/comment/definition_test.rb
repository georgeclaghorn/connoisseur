require "test_helper"

class Connoisseur::Comment::DefinitionTest < MiniTest::Test
  def test_define_blog
    comment = CLIENT.comment do |c|
      c.blog url: "https://example.com", language: "en", charset: "UTF-8"
    end

    assert_equal({ blog: "https://example.com", blog_lang: "en", blog_charset: "UTF-8" }, comment.parameters)
  end

  def test_define_post_with_timestamp
    comment = CLIENT.comment do |c|
      c.post url: "https://example.com/posts/hello-world", updated_at: Time.parse("2017-09-24 12:00:00 EDT")
    end

    assert_equal(
      {
        permalink: "https://example.com/posts/hello-world",
        comment_post_modified_gmt: "2017-09-24T16:00:00Z"
      },
      comment.parameters
    )
  end

  def test_define_post_without_timestamp
    comment = CLIENT.comment do |c|
      c.post url: "https://example.com/posts/hello-world"
    end

    assert_equal({ permalink: "https://example.com/posts/hello-world" }, comment.parameters)
  end

  def test_define_request
    comment = CLIENT.comment do |c|
      c.request ip_address: "24.29.18.175", user_agent: "Google Chrome", referrer: "https://example.com"
    end

    assert_equal(
      {
        user_ip: "24.29.18.175",
        user_agent: "Google Chrome",
        referrer: "https://example.com"
      },
      comment.parameters
    )
  end

  def test_define_author_without_role
    comment = CLIENT.comment do |c|
      c.author name: "Jane Smith", email_address: "jane@example.com", url: "https://example.com"
    end

    assert_equal(
      {
        comment_author: "Jane Smith",
        comment_author_email: "jane@example.com",
        comment_author_url: "https://example.com"
      },
      comment.parameters
    )
  end

  def test_define_author_with_role
    comment = CLIENT.comment do |c|
      c.author name: "Jane Smith", email_address: "jane@example.com", url: "https://example.com", role: :administrator
    end

    assert_equal(
      {
        comment_author: "Jane Smith",
        comment_author_email: "jane@example.com",
        comment_author_url: "https://example.com",
        user_role: :administrator
      },
      comment.parameters
    )
  end

  def test_define_type
    comment = CLIENT.comment { |c| c.type "comment" }
    assert_equal({ comment_type: "comment" }, comment.parameters)
  end

  def test_define_content
    comment = CLIENT.comment { |c| c.content "Nice post!" }
    assert_equal({ comment_content: "Nice post!" }, comment.parameters)
  end

  def test_define_creation_time
    comment = CLIENT.comment { |c| c.created_at Time.parse("2017-09-24 12:00:00 EDT") }
    assert_equal({ comment_date_gmt: "2017-09-24T16:00:00Z" }, comment.parameters)
  end

  def test_define_test
    comment = CLIENT.comment { |c| c.test! }
    assert_equal({ is_test: true }, comment.parameters)
  end

  def test_define_everything
    comment = CLIENT.comment do |c|
      c.blog url: "https://example.com", language: "en", charset: "UTF-8"
      c.post url: "https://example.com/posts/hello-world", updated_at: Time.parse("2017-09-24 12:00:00 EDT")
      c.request ip_address: "24.29.18.175", user_agent: "Google Chrome", referrer: "https://example.com"
      c.author name: "Jane Smith", email_address: "jane@example.com", url: "https://example.com", role: :administrator

      c.type "comment"
      c.content "Nice post!"
      c.created_at Time.parse("2017-09-24 12:00:00 EDT")

      c.test!
    end

    assert_equal(
      {
        blog: "https://example.com",
        blog_lang: "en",
        blog_charset: "UTF-8",
        permalink: "https://example.com/posts/hello-world",
        comment_post_modified_gmt: "2017-09-24T16:00:00Z",
        user_ip: "24.29.18.175",
        user_agent: "Google Chrome",
        referrer: "https://example.com",
        comment_author: "Jane Smith",
        comment_author_email: "jane@example.com",
        comment_author_url: "https://example.com",
        user_role: :administrator,
        comment_type: "comment",
        comment_content: "Nice post!",
        comment_date_gmt: "2017-09-24T16:00:00Z",
        is_test: true
      },
      comment.parameters
    )
  end
end
