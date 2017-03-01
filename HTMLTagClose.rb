require_relative 'HTMLTag.rb'

class HTMLTagClose < HTMLTag
    attr_accessor :opening_tag

    def initialize(html_line, str)
        super(html_line, str)
        #puts "Closing tag created: #{str}"
    end

    def has_opening_tag
        @opening_tag != nil ? (return true) : (return false)
    end
end 
