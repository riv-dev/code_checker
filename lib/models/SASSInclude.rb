class SASSInclude
    attr_accessor :codeline, :selector, :name, :parameters

    @@common_include_names = ['border-radius','transition','box-shadow','text-shadow','linear-gradient','radial-gradient','rotate',
                              'skew','scale','translate','opacity','background-size']

    def initialize(codeline, selector, name, parameters)
        @codeline = codeline
        @selector = selector
        @name = name
        @parameters = parameters
    end

    def self.get_common_include_names
        return @@common_include_names
    end

    def to_s
        return "@include #{@name}(#{@parameters});"
    end
end