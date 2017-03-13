class SASSSelector
    attr_accessor :codeline
    attr_accessor :name #Type string
    attr_accessor :pseudo_class #Type string
    attr_accessor :properties #Type array of SASSProperty's
    attr_accessor :includes #Type array of SASSInclude's
    attr_accessor :parent_selector #Type CSSSelector
    attr_accessor :children_selectors #Type array of children selectors

    def initialize(codeline, name, parent_selector)
        @codeline = codeline
        @name = name
        @pseudo_class = nil
        @properties = []
        @includes = []
        @parent_selector = parent_selector
        @children_selectors = []
    end

    def to_s
        return @name
    end

end