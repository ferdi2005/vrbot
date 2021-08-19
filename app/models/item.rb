class Item < ApplicationRecord
    reverse_geocoded_by :lat, :long
    validates :lat, presence: true
    validates :long, presence: true
    validates :title, presence: true
    validates :url, presence: true
end
