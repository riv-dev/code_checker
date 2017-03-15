class SASSProperty

    attr_accessor :codeline
    attr_accessor :selector
    attr_accessor :name
    attr_accessor :value

    def initialize(codeline, selector, name, value)
        @codeline = codeline
        @selector = selector
        @name = name
        @value = value
    end

    #The selector string to get the specific element
    #the style applies to
    def element_selector_string
        return @selector.element_selector_string
    end   

    def to_s
        return "#{@name}: #{@value};"
    end

end