#encoding: utf-8
class SASSProperty

    attr_accessor :codeline
    attr_accessor :parent
    attr_accessor :name
    attr_accessor :value

    def initialize(codeline, parent, name, value)
        @codeline = codeline
        @parent = parent
        @name = name
        @value = value
    end

    #The selector string to get the specific element
    #the style applies to
    def element_selector_string
        return @parent.element_selector_string
    end   

    def to_s
        return "#{@name}: #{@value};"
    end

end