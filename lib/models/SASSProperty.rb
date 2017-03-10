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

    def to_s
        return "#{@name}: #{@value}"
    end

end