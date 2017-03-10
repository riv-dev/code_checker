class SASSSelector
    attr_accessor :codeline
    attr_accessor :selector_name #Type string
    attr_accessor :pseudo_class #Type string
    attr_accessor :properties #Type array of strings
    attr_accessor :parent_selector #Type CSSSelector
    attr_accessor :children_selectors #Type array of children selectors

    def initialize(codeline, name, parent_selector)
        @codeline = codeline
        @selector_name = name
        @pseudo_class = nil
        @properties = []
        @parent_selector = parent_selector
        @children_selectors = []
    end

    def to_s
        return @selector_name
    end

end