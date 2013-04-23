class Product < ActiveRecord::Base
  attr_accessible :description, :manufacturer_id, :product_name
  belongs_to :contains_product, class_name: "ContainsProduct"
  has_many :to_buys, dependent: :destroy

  validates :description, presence: true
  validates :product_name, presence: true, length: { maximum: 50}

  def full_name
  	product_name
  	# "#{product_name} - #{Manufacturer.find(self.manufacturer_id).manufacturer_name}"
  end
end
