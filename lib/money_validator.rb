class MoneyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors[attribute] << I18n.translate("activemodel.errors.money.invalid_money") unless value.respond_to?(:numeric?) && value.numeric?
  end
end