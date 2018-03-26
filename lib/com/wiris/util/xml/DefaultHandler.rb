module WirisPlugin
include  Wiris
    require('com/wiris/util/xml/ContentHandler.rb')
    require('com/wiris/util/xml/ContentHandler.rb')
    class DefaultHandler
    extend ContentHandlerInterface

    include Wiris

        def initialize()
            super()
        end
        def startElement(uri, localName, qName, atts)
        end
        def endElement(uri, localName, qName)
        end
        def characters(ch)
        end
        def startDocument()
        end
        def endDocument()
        end

    end
end
