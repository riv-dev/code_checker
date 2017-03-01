class HTMLTag
    attr_accessor :html_line #Type HTMLLine
    attr_accessor :str #Type String
    attr_accessor :type #Type String

    def initialize(html_line, str)
        @html_line = html_line
        @str = str
        @type = str.match(/<\s*\/?\s*(\w+)\s*.*>/).captures[0]
    end
end