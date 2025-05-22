# DRY:
# Since we have to round up almost everywhere in the codebase, we can create a concern that will take care of this for us. This way,
# we can just include it in the models that need it and specify which attributes to round up.
module RoundMoneyValues
  extend ActiveSupport::Concern

  included do
    before_validation :round_money_attributes
  end

  private

  # Rounds each attribute defined in the class method `money_attributes` to 2 decimal places.
  #
  # @return [void]
  def round_money_attributes
    self.class.rounded_money_attributes.each do |attr|
      value = public_send(attr)
      public_send("#{attr}=", value.round(2)) if value.respond_to?(:round)
    end
  end

  class_methods do
    # Sets the list of attributes that should be rounded up before validation.
    #
    # @param attrs [Array<Symbol, String>] list of attribute names
    #
    # @return [void]
    def attributes_to_round_up(*attrs)
      @rounded_money_attributes = attrs.map(&:to_sym)
    end

    # Gets the list of attributes that should be rounded.
    #
    # @return [Array<Symbol>] the configured attributes, or an empty array if none
    def rounded_money_attributes
      @rounded_money_attributes || []
    end
  end
end
