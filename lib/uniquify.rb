module Mongoid::Uniquify

  def ensure_unique(name)
    begin
      self[name] = yield
    end while self.class.where(name => self[name]).exists?
  end
  
  module ClassMethods

    def field_with_uniquify(name, options = {})
      if options[:uniquify]
        default = { :length => 8, :chars => ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a, :string => String }
        options = default.merge!(options)

        field_without_uniquify(name, options)
                
        class_eval do
          validates_uniqueness_of name, :on => :create
          before_create do |record|
            record.ensure_unique(name) do
              Array.new(options[:length]) { options[:chars].to_a[rand(options[:chars].to_a.size)] }.join
            end
          end
        end
      else
        field_without_uniquify(name, options)
      end
    end
  end

  def self.included(receiver)
    receiver.class_eval do
      extend ClassMethods
      class << self
        alias_method_chain :field, :uniquify
      end
    end
  end
end