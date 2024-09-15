# app/models/api_repository.rb
class ApiRepository < ApplicationRecord
  validates :api_name, presence: true
  validates :base_url, presence: true
end
