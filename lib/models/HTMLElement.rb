class HTMLElement
   attr_accessor :code_line #Type HTMLLine
   attr_accessor :str #Type String

   def initialize(code_line, str)
        @code_line = code_line
        @str = str
   end
end