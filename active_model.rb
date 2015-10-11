#it guaranties that records will only be validated once if associated

module ActiveModel

  module Validations

    def valid?(context = nil)
      current_context, self.validation_context = validation_context, context
      errors.clear
      if !@record_in_validation
        @record_in_validation=true
        run_validations!
      else
        true
      end
    ensure
      @record_in_validation=false
      self.validation_context = current_context
    end

    alias_method :validate, :valid?
  end
end