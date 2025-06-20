class User < ApplicationRecord
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
