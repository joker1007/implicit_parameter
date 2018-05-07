require "implicit_parameter/version"
require "binding_ninja"

module ImplicitParameter
  module Caller
    def implicit(*name)
      @implicit_values ||= []
      @implicit_values.concat(name)
    end

    def implicit_values
      @implicit_values ||= []
      if superclass.respond_to?(:implicit_values)
        @implicit_values + superclass.implicit_values
      else
        @implicit_values
      end
    end
  end

  class ExtensionBase < Module
    def inspect
      "#<ExtensionBase:#{object_id}>"
    end
  end
  private_constant :ExtensionBase

  module Callee
    def implicit_paramter(method, klass)
      @implicit_parameter_extension = Module.new do
        extend BindingNinja
      end

      unless @implicit_parameter_extension.method_defined?(method)
        @implicit_parameter_extension.module_eval do
          define_method(method) do |b, *args|
            caller_instance = b.receiver
            value = nil
            if caller_instance.class.respond_to?(:implicit_values)
              value = caller_instance.class.implicit_values.inject(nil) do |result, value_name|
                break result if result

                v = caller_instance.instance_eval(value_name.to_s) rescue nil
                if v.is_a?(klass)
                  v
                end
              end
            end
            super(value, *args)
          end
          auto_inject_binding(method)
        end
      end

      unless include?(@implicit_parameter_extension)
        prepend @implicit_parameter_extension
      end

      binding_ninja_mod = BindingNinja.instance_variable_get("@auto_inject_binding_extensions")[@implicit_parameter_extension]
      unless include?(binding_ninja_mod)
        prepend binding_ninja_mod
      end
    end
  end
end
