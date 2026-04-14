require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "normalizes email: lowercase, stripped, nil for blank" do
    user = User.new(email: "  MixedCase@Example.COM  ")
    assert_equal "mixedcase@example.com", user.email

    user.email = ""
    assert_nil user.email
  end

  test "normalizes phone: digits only, nil for blank" do
    user = User.new(phone: "(555) 123-4567")
    assert_equal "5551234567", user.phone

    user.phone = ""
    assert_nil user.phone
  end

  test "requires either email or phone" do
    user = User.new(password: "correct horse battery staple")
    assert_not user.valid?
    assert_includes user.errors[:base], "Please provide either an email address or a phone number"

    user.phone = "5551234567"
    assert user.valid?
  end

  test "rejects invalid email format" do
    user = User.new(email: "not-an-email", password: "correct horse battery staple")
    assert_not user.valid?
    assert_includes user.errors[:email], "is not a valid email address"
  end

  test "rejects phone with fewer than 10 digits" do
    user = User.new(phone: "123", password: "correct horse battery staple")
    assert_not user.valid?
    assert_includes user.errors[:phone], "must be a valid phone number"
  end

  test "enforces case-insensitive email uniqueness" do
    User.create!(email: "duplicate@example.com", password: "correct horse battery staple")
    dup = User.new(email: "DUPLICATE@example.com", password: "correct horse battery staple")
    assert_not dup.valid?
    assert_includes dup.errors[:email], "has already been taken"
  end

  test "enforces phone uniqueness across formats" do
    User.create!(phone: "5551234567", password: "correct horse battery staple")
    dup = User.new(phone: "(555) 123-4567", password: "correct horse battery staple")
    assert_not dup.valid?
    assert_includes dup.errors[:phone], "has already been taken"
  end

  test "requires password of at least 12 characters" do
    user = User.new(email: "short@example.com", password: "too short")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 12 characters)"
  end

  test "find_by_login returns user for email (any case)" do
    user = users(:one)
    assert_equal user, User.find_by_login("ONE@example.com")
  end

  test "find_by_login returns user for phone (any formatting)" do
    user = users(:phone_only)
    assert_equal user, User.find_by_login("(555) 111-2222")
    assert_equal user, User.find_by_login("5551112222")
  end

  test "find_by_login returns nil for blank or unknown identifier" do
    assert_nil User.find_by_login("")
    assert_nil User.find_by_login(nil)
    assert_nil User.find_by_login("unknown@example.com")
  end

  test "authenticate_by_login succeeds with correct password" do
    user = users(:one)
    assert_equal user, User.authenticate_by_login(identifier: user.email, password: "correct horse battery staple")
  end

  test "authenticate_by_login fails with wrong password" do
    user = users(:one)
    assert_nil User.authenticate_by_login(identifier: user.email, password: "wrong password here!")
  end

  test "authenticate_by_login works with phone identifier" do
    user = users(:phone_only)
    assert_equal user, User.authenticate_by_login(identifier: "(555) 111-2222", password: "correct horse battery staple")
  end

  test "can clear email while keeping phone" do
    user = User.create!(email: "dual@example.com", phone: "5552223333", password: "correct horse battery staple")
    assert user.update(email: "")
    assert_nil user.reload.email
    assert_equal "5552223333", user.phone
  end

  test "cannot clear both email and phone" do
    user = User.create!(email: "dual2@example.com", phone: "5553334444", password: "correct horse battery staple")
    assert_not user.update(email: "", phone: "")
    assert_includes user.errors[:base], "Please provide either an email address or a phone number"
  end
end
