#encoding: utf-8
require_relative 'HTMLTag.rb'

class HTMLTagClose < HTMLTag
    attr_accessor :opening_tag

    def initialize(code_line, str)
        super(code_line, str)
        #puts "Closing tag created: #{str}"
    end

    def has_opening_tag
        @opening_tag != nil ? (return true) : (return false)
    end
end 
