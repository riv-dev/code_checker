class HTMLTag
    attr_accessor :html_line #Type HTMLLine
    attr_accessor :str #Type String
    attr_accessor :type #Type String

    def initialize(html_line, str)
        @html_line = html_line
        @str = str
        @type = str.match(/<\s*\/?\s*(\w+)\s*.*>/).captures[0]
    end

    def HTMLTag::is_closing_tag(str)
        str.match(/<\s*\/?\s*(\w+)\s*.*>/)
    end

    def to_s
        @str
    end
end