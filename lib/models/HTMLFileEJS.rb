class HTMLFileEJS < HTMLFile
    @@open_ejs_detected = false

    #Override
    def process_line_through_templating_engine(str)
        #remove ejs <%  %>
        if @@open_ejs_detected and str.gsub!(/.*?\s*%>/, ' ')
            #puts "end of ejs"
            #puts "  #{str}"
            @@open_ejs_detected = false
        elsif @@open_ejs_detected
            #puts "ejs ignored"
            #puts "  #{str}"
            str = ""
        elsif str.gsub!(/<%\s*.*?\s*%>/, ' ')
            #puts "ejs removed"
            #puts " #{str}"
            @@open_ejs_detected = false
        elsif str.gsub!(/<%\s*.*/, ' ')
            #puts "open ejs detected line:#{@line_number}}"
            #puts "  #{str}"
            @@open_ejs_detected = true
        end

        return str
    end
end