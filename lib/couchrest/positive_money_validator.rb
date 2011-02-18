class PositiveMoneyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && value.respond_to?(:numeric?) && value.numeric? && (value.to_s.gsub(',', '.').to_f * 100.0).to_i < 0
      record.errors[attribute] << I18n.translate("activemodel.errors.money.not_positive")
    end
  end
end