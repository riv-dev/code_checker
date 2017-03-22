class SASSSelector
    attr_accessor :codeline
    attr_accessor :name #Type string
    attr_accessor :properties #Type array of SASSProperty's
    attr_accessor :includes #Type array of SASSInclude's
    attr_accessor :parent #Type CSSSelector
    attr_accessor :children_selectors #Type array of children selectors

    def initialize(codeline, name, parent)
        @codeline = codeline
        @name = name
        @pseudo_class = nil
        @properties = []
        @includes = []
        @parent = parent
        @children_selectors = []
    end

    #The selector string to get the specific element
    #the style applies to
    def element_selector_string
        if @name.match(/^\s*@media/) or @name.match(/^\s*&\s*:\w+\s*$/) 
            @parent ? (return "#{@parent.element_selector_string}".strip ) : (return "Error")
        elsif @name.match(/\s*(.+?)\s*&?:\w+\s*/) #E.g. .no-touchevents &:hover { }
            new_str = @name.gsub(/\s*(.+?)\s*&?:\w+\s*/,'\1')
            @parent ? (return "#{new_str} #{@parent.element_selector_string}".strip ) : (return new_str)            
        elsif @name.match(/\s*(.+?)\s*:\w+\s*/)
            new_str = @name.gsub(/\s*(.+?)\s*:\w+\s*/,'\1')
            @parent ? (return "#{@parent.element_selector_string} #{new_str}".strip ) : (return new_str)
        elsif captures = @name.match(/&\s*([\.\#\-_\w]+)/)
            @parent ? (return "#{@parent.element_selector_string}#{captures[1]}".strip) : (return "Error")
        elsif captures = @name.match(/\s*([\.\#\-_\w]+)\s*&$/) #E.g. .no-touchevents & { }
            @parent ? (return " #{captures[1]} #{@parent.element_selector_string}".strip) : (return "Error")
        else
            @parent ? (return "#{@parent.element_selector_string} #{@name}".strip ) : (return @name)
        end
    end

    def to_s
        return @name
    end

end