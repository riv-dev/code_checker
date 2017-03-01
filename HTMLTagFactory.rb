require_relative 'HTMLTagOpen'
require_relative 'HTMLTagClose'
require_relative 'HTMLTagVoid'

class HTMLTagFactory
    def HTMLTagFactory::create(html_line, str)
        if str.match(/<\s*(\w+)\s*.*(\/\s*>)$/)
            return HTMLTagVoid.new(html_line, str)
        elsif str.match(/<\s*\/\s*(\w+)\s*.*(\s*>)$/)
            return HTMLTagClose.new(html_line, str)
        elsif str.match(/<\s*(\w+)\s*.*(\s*>)$/)
            return HTMLTagOpen.new(html_line, str)
        else
            return nil #invalid tag
        end
     end
end