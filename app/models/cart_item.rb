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

  # matches .attributes
  def to_a
    [
      self.description,
      self.details,
      self.vendor,
      self.url,
      self.notes,
      self.part_number,
      self.green?,
      self.features,
      self.socio,
      self.quantity,
      self.price,
      self.quantity * self.price
    ]
  end

  def initialize_traits(traits_params)
    traits_params.each do |trait|
      if trait[1].kind_of?(Array)
        trait[1].each do |individual|
          build_traits(trait[0], individual) if individual.present?
        end
      else
        build_traits(trait[0], trait_value(trait))
      end
    end
  end

  def build_traits(name, value)
    cart_item_traits.build(name: name, value: value)
  end

  # matches #to_a
  def self.attributes
    [
      'description',
      'details',
      'vendor',
      'url',
      'notes',
      'part_number',
      'green',
      'features',
      'socio',
      'quantity',
      'unit price',
      'price for quantity'
    ]
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
      cart.set_props(props)
    end

    cart
  end

  def trait_value trait
    trait[1].presence || "true"
  end

end
