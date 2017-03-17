require_relative 'HTMLTag.rb'

class HTMLTagOpen < HTMLTag
    attr_accessor :id #type String
    attr_accessor :classes #type Array of Strings
    attr_accessor :attributes #type Hash
    attr_accessor :closing_tag #type HTMLTagClose
    attr_accessor :parent
    attr_accessor :children

    def initialize(code_line, str)
        super(code_line, str)

        @parent = nil
        @children = []

        #puts "Opening tag created: #{str}"
    end

    def has_closing_tag
        @closing_tag != nil ? (return true) : (return false)
    end

    def closing_tag_line_number
        return @closing_tag.code_line.line_number if @closing_tag != nil
    end
end