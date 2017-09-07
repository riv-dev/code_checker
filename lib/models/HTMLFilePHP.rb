#encoding: utf-8
class HTMLFilePHP < HTMLFile
    @@open_php_detected = false


    #override
    def process_line_through_templating_engine (str)
        #remove phps <?php ?>
        if @@open_php_detected and str.gsub!(/.*?\s+\?>/, ' ')
            #puts "end of php"
            #puts "  #{str}"
            @@open_php_detected = false
        elsif @@open_php_detected
            #puts "php ignored"
            #puts "  #{str}"
            str = ""
        elsif str.gsub!(/<\?php\s+.*?\s+\?>/, ' ')
            #puts "php removed"
            #puts " #{str}"
            @@open_php_detected = false
        elsif str.gsub!(/<\?php\s+.*/, ' ')
            #puts "open php detected line:#{@line_number}}"
            #puts "  #{str}"
            @@open_php_detected = true
        end

        return str
    end

end