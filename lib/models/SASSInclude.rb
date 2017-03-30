class SASSInclude
    attr_accessor :codeline, :parent, :name, :parameters

    @@common_include_names = ['border-radius','transition','box-shadow','text-shadow','linear-gradient','radial-gradient','rotate',
                              'skew','scale','translate','opacity','background-size', 'transform']

    def initialize(codeline, parent, name, parameters)
        @codeline = codeline
        @parent = parent
        @name = name
        @parameters = parameters
    end

    def self.get_common_include_names
        return @@common_include_names
    end

    #The selector string to get the specific element
    #the style applies to
    def element_selector_string
        return @parent.element_selector_string
    end 

    def to_s
        return "@include #{@name}(#{@parameters});"
    end
end