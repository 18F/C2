class CartItem < ActiveRecord::Base
  include PropMixin
  belongs_to :cart
  has_many :cart_item_traits
  has_many :comments, as: :commentable
  has_many :properties, as: :hasproperties

  def green?
    cart_item_traits.map(&:name).include?('green')
  end

  def features
    cart_item_traits.select{ |trait| trait.name.include?("feature") }.map(&:value)
  end

  def socio
    cart_item_traits.select{ |trait| trait.name.include?("socio") }.map(&:value)
  end

  def formatted_price
    "$#{'%.2f' % price}"
  end

  def subtotal
    "$#{'%.2f' % (price * quantity)}"
  end

  def initialize_traits(traits_params)
    traits_params.each do |trait|
      if trait[1].kind_of?(Array)
        trait[1].each do |individual|
          if individual.present?
            self.cart_item_traits.build(
              name: trait[0],
              value: individual
            )
          end
        end
      end
    end
  end

  def import_properties(props)
    props.each do |key,val|
      self.setProp(key, val)
    end
  end

  def self.from_params(params)
    cart = self.new(
      :vendor => params.fetch(:vendor, nil),
      :description => params.fetch(:description, nil),
      :url => params.fetch(:url, nil),
      :notes => params.fetch(:notes, nil),
      :quantity => params.fetch(:qty , 0),
      :details => params.fetch(:details, nil),
      :part_number => params.fetch(:partNumber , nil),
      :price => params.fetch(:price, nil).gsub(/[\$\,]/,"").to_f
    )

    traits_params = params[:traits] || []
    cart.initialize_traits(traits_params)

    props = params[:properties]
    unless props.blank?
      cart.import_properties(props)
    end

    cart
  end
end
