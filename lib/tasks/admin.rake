namespace :admin do
  desc "Create (or promote) a site admin user. Pass EMAIL=, PASSWORD= env vars or you'll be prompted."
  task create: :environment do
    require "io/console"

    email = ENV["EMAIL"].presence
    password = ENV["PASSWORD"].presence

    if email.blank?
      print "Email: "
      email = $stdin.gets&.strip
    end
    abort "Email is required." if email.blank?

    if password.blank?
      print "Password (min #{User::PASSWORD_MIN_LENGTH} chars): "
      password = $stdin.noecho(&:gets)&.strip
      puts
    end
    abort "Password is required." if password.blank?

    user = User.find_or_initialize_by(email: email.strip.downcase)
    user.password = password
    user.role = :site_admin

    if user.save
      puts "Site admin #{user.email} is ready."
    else
      abort "Could not save user: #{user.errors.full_messages.to_sentence}"
    end
  end
end
