#encoding: utf-8
class SASSKeyFrames
    attr_accessor :codeline
    attr_accessor :name #Type string
    attr_accessor :properties #Type array of SASSProperty's
    attr_accessor :includes #Type array of SASSInclude's
    attr_accessor :children_selectors #Type array of children selectors

    def initialize(codeline, name)
        @codeline = codeline
        @name = name
        @properties = []
        @includes = []
        @children_selectors = []
    end

    #Mixins don't select any element
    def element_selector_string
        return "@keyframes"
    end    

    def to_s
        return "@keyframes #{@name}"
    end   
end