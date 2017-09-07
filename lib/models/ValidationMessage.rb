#encoding: utf-8
class ValidationMessage
    attr_accessor :line
    attr_accessor :message
    attr_accessor :source

    def initialize(line, message, source)
        @line = line
        @message = message
        @source = source
    end
end