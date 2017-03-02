require_relative 'HTMLTagOpen.rb'
require_relative 'HTMLTagClose.rb'
require_relative 'HTMLTagVoid.rb'

class HTMLTagFactory
    def HTMLTagFactory::create(html_line, str)
        if str.match(/<\s*(\w+)\s*.*(\/\s*>)$/) #e.g. <img src="hbr.jpg" />
            if HTMLTagVoid.is_type_void(str)
                if HTMLTagVoid.is_valid_void_tag(str)
                    return HTMLTagVoid.new(html_line, str)
                else
                    return nil
                end
            else
                return nil #invalid tag
            end
        elsif str.match(/<\s*\/\s*(\w+)\s*.*(\s*>)$/) #e.g. </h1>
            if HTMLTagVoid.is_type_void(str)
                return nil #invalid tag
            else
                return HTMLTagClose.new(html_line, str)
            end
        elsif str.match(/<\s*(\w+)\s*.*(\s*>)$/) #e.g. <p class="history">
            if HTMLTagVoid.is_type_void(str)
                if HTMLTagVoid.is_valid_void_tag(str)
                    return HTMLTagVoid.new(html_line, str)
                else
                    return nil
                end
            else
                return HTMLTagOpen.new(html_line, str)
            end
        else
            return nil #invalid tag
        end
     end
end