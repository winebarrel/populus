require 'populus/dsl'

module Populus
  module Helpers
    extend self

    def define_helper(name, &block)
      m = Module.new do
        define_method(name, &block)
      end
      Populus.logger.info "Register helper: #{name}"
      DSL::DSLContext.send :include, m
    end
  end
end

Dir.glob("#{File.dirname __FILE__}/helpers/*.rb").each do |helper|
  require helper
end
