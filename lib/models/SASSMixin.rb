class SASSMixin
    attr_accessor :codeline
    attr_accessor :name #Type string
    attr_accessor :properties #Type array of strings
    attr_accessor :children_selectors #Type array of children selectors

    def initialize(codeline, name)
        @codeline = codeline
        @name = name
        @properties = []
        @children_selectors = []
    end

    def to_s
        return @name
    end

end