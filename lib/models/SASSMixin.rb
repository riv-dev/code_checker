class SASSMixin
    attr_accessor :codeline
    attr_accessor :name #Type string
    attr_accessor :parameters
    attr_accessor :properties #Type array of SASSProperty's
    attr_accessor :includes #Type array of SASSInclude's
    attr_accessor :children_selectors #Type array of children selectors

    def initialize(codeline, name, parameters)
        @codeline = codeline
        @name = name
        @parameters = parameters
        @properties = []
        @includes = []
        @children_selectors = []
    end

    #Mixins don't select any element
    def element_selector_string
        return "@mixin"
    end    

    def to_s
        return "@mixin #{@name}(#{@parameters})"
    end

end