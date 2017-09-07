#encoding: utf-8
class SASSDirective
    attr_accessor :codeline
    attr_accessor :name

    def initialize(codeline, name)
        @codeline = codeline
        @name = name
    end
end