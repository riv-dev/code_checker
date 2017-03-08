class HTMLElement
   attr_accessor :html_line #Type HTMLLine
   attr_accessor :str #Type String

   def initialize(html_line, str)
        @html_line = html_line
        @str = str
   end
end