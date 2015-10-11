
module ActiveRecord::Associations::Builder
  class Association

    def self.define_accessors(model, reflection)
      mixin = model.generated_association_methods
      name = reflection.name
      define_single_access(mixin, name) if [:has_one, :belongs_to].include?(reflection.macro)
      define_readers(mixin, name)
      define_writers(mixin, name)
    end

    def self.define_single_access(mixin, name)
      mixin.class_eval <<-CODE, __FILE__, __LINE__ + 1
      
        def #{name}_target(*args)
          association(:#{name}).target
        end

        def #{name}_ass(*args)
          association(:#{name})
        end

      CODE
    end

  end
end
