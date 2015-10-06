module IncomingMail
  class Response
    attr_accessor :type, :action, :comment

    # named action constants
    ERROR   = 0 
    COMMENT = 1 
    DROPPED = 2 

    def initialize(params = {}) 
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end 
      @action ||= ERROR # default is pessimistic (realistic?)
    end 
  end
end
