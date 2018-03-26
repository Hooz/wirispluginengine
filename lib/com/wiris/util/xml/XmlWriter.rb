module WirisPlugin
include  Wiris
    require('com/wiris/util/xml/WXmlUtils.rb')
    require('com/wiris/util/xml/ContentHandler.rb')
    require('com/wiris/util/xml/ContentHandler.rb')
    class XmlWriter
    extend ContentHandlerInterface

    include Wiris

    INDENT_STRING = "   "
    ECHO_FILTER = 2
    AUTO_IGNORING_SPACE_FILTER = 1
    PRETTY_PRINT_FILTER = 0
    @prettyPrint;
        attr_accessor :prettyPrint
    @xmlDeclaration;
        attr_accessor :xmlDeclaration
    @autoIgnoringWhitespace;
        attr_accessor :autoIgnoringWhitespace
        attr_accessor :inlineElements
        attr_accessor :filter
    @ignoreEntities;
        attr_accessor :ignoreEntities
        attr_accessor :tagOpen
        attr_accessor :firstLine
        attr_accessor :isInline
        attr_accessor :inlineMark
        attr_accessor :depth
        attr_accessor :cdataSection
        attr_accessor :currentPrefixes
        attr_accessor :hasWhiteSpace
        attr_accessor :nameSpace
        attr_accessor :whiteSpace
        attr_accessor :sb
        def initialize()
            super()
            @filter = PRETTY_PRINT_FILTER
            @xmlDeclaration = false
            @inlineElements = Array.new()
            @firstLine = generateFirstLine("UTF-8")
            reset()
        end
        def setFilter(filterType)
            @filter = filterType
        end
        def getFilter()
            return @filter
        end
        def setXmlDeclaration(xmlFragment)
            @xmlDeclaration = xmlFragment
        end
        def isXmlDeclaration()
            return @xmlDeclaration
        end
        def setInlineElements(inlineElements)
            if inlineElements != nil
                @inlineElements = inlineElements
            else 
                @inlineElements = Array.new()
            end
        end
        def getInlineElements()
            return @inlineElements
        end
        def startDocument()
            reset()
            if @xmlDeclaration
                write(@firstLine)
            end
            if !@prettyPrint
                write("\n")
            end
        end
        def endDocument()
            closeOpenTag(false)
        end
        def startPrefixMapping(prefix, uri)
            if (uri == @currentPrefixes::get(prefix))
                return 
            end
            if uri::length() == 0
                return 
            end
            pref = prefix
            if prefix::length() > 0
                pref = ":" + prefix
            end
            ns = (((" xmlns" + pref) + "=\"") + uri) + "\""
            @nameSpace::add(ns)
            @currentPrefixes::set(prefix,uri)
        end
        def endPrefixMapping(prefix)
            @currentPrefixes::remove(prefix)
        end
        def startElement(uri, localName, qName, atts)
            closeOpenTag(false)
            processWhiteSpace(@isInline || !(@autoIgnoringWhitespace || @prettyPrint))
            if @prettyPrint && !@isInline
                writeIndent()
            end
            name = qName
            if (name == nil) || (name::length() == 0)
                name = localName
            end
            write("<" + name)
            writeAttributes(atts)
            if @nameSpace != nil
                write(@nameSpace::toString())
                @nameSpace = nil
            end
            @tagOpen = true
            if !@isInline && @inlineElements::contains_(name)
                @inlineMark = @depth
                @isInline = true
            end
            @depth+=1
        end
        def endElement(uri, localName, qName)
            name = qName
            if (name == nil) || (name::length() == 0)
                name = localName
            end
            writeSpace = (@tagOpen || @isInline) || !(@autoIgnoringWhitespace || @prettyPrint)
            processWhiteSpace(writeSpace)
            @depth-=1
            if @tagOpen
                closeOpenTag(true)
            else 
                if (!@isInline && @prettyPrint) && !writeSpace
                    writeIndent()
                end
                write(("</" + name) + ">")
            end
            if @isInline && (@inlineMark == @depth)
                @isInline = false
                @inlineMark = -1
            end
        end
        def startCDATA()
            closeOpenTag(false)
            write("<![CDATA[")
            @cdataSection = true
        end
        def endCDATA()
            @cdataSection = false
            write("]]>")
        end
        def characters(ch)
            if @cdataSection
                @sb::add(ch)
            else 
                if !@isInline
                    if XmlWriter.isWhiteSpace(ch)
                        @hasWhiteSpace = true
                        @whiteSpace::add(ch)
                        return 
                    else 
                        processWhiteSpace(true)
                        @inlineMark = @depth - 1
                        @isInline = true
                    end
                end
                closeOpenTag(false)
                if @ignoreEntities
                    @sb::add(ch)
                else 
                    @sb::add(WXmlUtils::htmlEscape(ch))
                end
            end
        end
        def write(s)
            @sb::add(s)
        end
        def writeText(s)
            @sb::add(WXmlUtils::htmlEscape(s))
        end
        def self.isWhiteSpace(text)
            it = Utf8::getIterator(text)
            while it::hasNext()
                c = it::next()
                if (((c != 32) && (c != 10)) && (c != 13)) && (c != 9)
                    return false
                end
            end
            return true
        end
        def closeOpenTag(endElement)
            if @tagOpen
                if endElement
                    write("/")
                end
                write(">")
                @tagOpen = false
            end
        end
        def writeAttributes(atts)
            if atts == nil
                return 
            end
            for i in 0..atts::getLength() - 1
                name = atts::getName(i)
                value = atts::getValue(i)
                if name::startsWith("xmlns")
                    prefix = nil
                    uri = value
                    if name::length() > 5
                        if Std::charCodeAt(name,6) == 54
                            prefix = Std::substr(name,6)
                        end
                    else 
                        prefix = ""
                    end
                    if (prefix != nil) && (uri == @currentPrefixes::get(prefix))
                            next
                    end
                end
                write(" ")
                write(name)
                write("=\"")
                writeText(value)
                write("\"")
                i+=1
            end
        end
        def processWhiteSpace(write)
            if @hasWhiteSpace && write
                closeOpenTag(false)
                writeText(@whiteSpace::toString())
            end
            @whiteSpace = StringBuf.new()
            @hasWhiteSpace = false
        end
        def writeIndent()
            write("\n")
            for i in 0..@depth - 1
                write(INDENT_STRING)
                i+=1
            end
        end
        def generateFirstLine(encoding)
            return ("<?xml version=\"1.0\" encoding=\"" + encoding) + "\"?>"
        end
        def reset()
            @tagOpen = false
            @isInline = false
            @inlineMark = -1
            @depth = 0
            @cdataSection = false
            @hasWhiteSpace = false
            @currentPrefixes = Hash.new()
            @whiteSpace = StringBuf.new()
            @nameSpace = StringBuf.new()
            @sb = StringBuf.new()
            if @filter == PRETTY_PRINT_FILTER
                @autoIgnoringWhitespace = true
                @prettyPrint = true
            else 
                if @filter == AUTO_IGNORING_SPACE_FILTER
                    @autoIgnoringWhitespace = true
                    @prettyPrint = false
                else 
                    @autoIgnoringWhitespace = false
                    @prettyPrint = false
                end
            end
        end
        def toString()
            return sb::toString()
        end

    @prettyPrint = true
    @xmlDeclaration = false
    @autoIgnoringWhitespace = true
    @ignoreEntities = false
    end
end
