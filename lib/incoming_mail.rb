module IncomingMail
  class Handler
    # parses a Mandrill callback object and Does The Right Thing

    def handle(payload)
      resp = Response.new

      resp
    end
  end

  class Response
    attr_accessor :action, :comment

    # named action constants
    ERROR = 0
    COMMENT = 1
    DROPPED = 2

  end
end
