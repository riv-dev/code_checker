require_relative 'HTMLElement.rb'

class HTMLTag < HTMLElement
    attr_accessor :type #Type String
    attr_accessor :id
    attr_accessor :classes

    all_tags = ['!DOCTYPE', 
                'a', 'abbr','acryonym','address','applet','area','article','aside','audio',
                'b','base','basefont','bdi','bdo','big','blockquote','body','br','button','canvas','caption','center','cite','code','col','colgroup',
                'data','datalist','dd','del','details','dfn','dialog','dir','div','dl','dt',
                'em','embed',
                'fieldset','figcaption','figure','font','footer','form','frame','frameset',
                'h1','h2','h3','h4','h5','h6','head','header','hr','html',
                'i','iframe','img','input','ins',
                'kbd','keygen',
                'label','legend','li','link',
                'main','map','mark','menu','menuitem','meta','meter',
                'nav','noframes','noscript',
                'object','ol','optgroup','option','output',
                'p','path','param','picture','pre','progress',
                'q','quote','rp','rt','ruby',
                's','samp','script','section','select','small','source','span','strike','strong','style','sub','summary','sup','svg',
                'table','tbody','td','textarea','tfoot','th','thead','time','title','tr','track','tt',
                'u','ul','var','video','wbr']

    def initialize(html_line, str)
        super(html_line, str)
        @type = str.match(/<\s*\/?\s*(\w+)\s*.*>/).captures[0]
        @inner_html = []
        @id = nil
        @classes = []
    end

    def to_s
        @str
    end
end