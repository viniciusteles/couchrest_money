RSpec::Matchers.define :have_errors do
  match do |actual|
    actual.errors.size > 0
  end

  failure_message_for_should do |actual|
    "expected that #{actual.class} would have errors"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.class} would not have errors, instead it has #{actual.errors.size} error(s)\n" +
    actual.errors.inspect
  end

  description do
    "have errors"
  end
end

RSpec::Matchers.define :contain_error do |attribute, error_message|
  match do |actual|
    actual.errors[attribute].should include(error_message)
  end
  
  failure_message_for_should do |actual|
    "expected that #{actual.class}.#{attribute} would contain the error message: #{error_message}, instead it has the error messages:\n#{actual.errors[attribute]}" 
  end
  
  failure_message_for_should_not do |actual|
    "expected that #{actual.class}.#{attribute} whould not contail the error message: #{error_message}"
  end
  
  description do
    "contaion error"
  end
end