class SASSSelector
    attr_accessor :codeline
    attr_accessor :name #Type string
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

    #The selector string to get the specific element
    #the style applies to
    def element_selector_string
        if @name.match(/^\s*@media/) or @name.match(/^\s*&\s*:\w+\s*$/) 
            @parent_selector ? (return "#{@parent_selector.element_selector_string}") : (return nil)
        elsif captures = self.name.match(/^\s*(.+):\w+\s*/)
            @parent_selectr ? (return "#{@parent_selector.element_selector_string} #{captures[1]}") : (return captures[1])
        else
            @parent_selector ? (return "#{@parent_selector.element_selector_string} #{@name}") : (return @name)
        end
    end

    def to_s
        return @name
    end

end