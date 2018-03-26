module WirisPlugin
include  Wiris
    require('com/wiris/util/xml/WCharacterBase.rb')
    class SAXParser
    include Wiris

    CHAR_HASH = 35
    CHAR_AT = 64
    CHAR_OPEN_BRACKET = 123
    CHAR_CLOSE_BRACKET = 125
    CHAR_LINE_FEED = 10
    CHAR_CARRIAGE_RETURN = 13
    CHAR_SPACE = 32
    CHAR_TAB = 9
    CHAR_BACKSLASH = 92
    CHAR_DOUBLE_QUOT = 34
    CHAR_DOT = 46
    CHAR_LESS_THAN = 60
    CHAR_GREATER_THAN = 62
    CHAR_BAR = 47
    CHAR_EXCLAMATION = 33
    CHAR_INTERROGATION = 63
    CHAR_QUOT = 39
    CHAR_OPEN_SQUARE_BRACKET = 91
    CHAR_HYPHEN = 45
    CHAR_UNDERSCORE = 95
    CHAR_COLON = 58
    CHAR_X = 120
    CHAR_AMPERSAND = 38
    CHAR_SEMICOLON = 59
    BEGIN = 0
    BEGIN_NODE = 1
    TAG_NAME = 2
    ATTRIB = 3
    BODY = 4
    HEADER = 5
    COMMENT = 6
    IGNORE_SPACES = 7
    CHILDS = 8
    TAG_NAME_CLOSE = 9
    CDATA = 10
        attr_accessor :lineNumber
        attr_accessor :columnNumber
        attr_accessor :entityResolvers
    MALFORMED_XML = "Error: Malformed xml file."
        attr_accessor :index
        attr_accessor :current
        attr_accessor :last
        attr_accessor :xml
        attr_accessor :iterator
        def initialize()
            super()
            @lineNumber = -1
            @columnNumber = -1
            @entityResolvers = Array.new()
        end
        def getLineNumber()
            return @lineNumber
        end
        def getColumnNumber()
            return @columnNumber
        end
        def addEntityResolver(e)
            @entityResolvers::push(e)
        end
        def parse(source, c)
            if source::length() > 0
                @lineNumber = 1
                @columnNumber = 0
            end
            @xml = source
            @iterator = Utf8::getIterator(@xml)
            c::startDocument()
            state = IGNORE_SPACES
            nextState = BEGIN
            names = Array.new()
            attribs = Attributes.new()
            @index = 0
            lastIndex = 0
            characters = StringBuf.new()
            nextChar()
            while @current != -1
                if state == BEGIN
                    if @current == CHAR_LESS_THAN
                        state = BEGIN_NODE
                        nextState = BEGIN
                    else 
                        raise Exception,MALFORMED_XML
                    end
                else 
                    if state == BEGIN_NODE
                        if @current == CHAR_EXCLAMATION
                            nextChar()
                            if @current == CHAR_HYPHEN
                                nextChar()
                                if @current == CHAR_HYPHEN
                                    state = COMMENT
                                        next
                                else 
                                    raise Exception,MALFORMED_XML
                                end
                            else 
                                if @current == CHAR_OPEN_SQUARE_BRACKET
                                    if searchString("CDATA[")
                                        state = CDATA
                                    else 
                                        raise Exception,MALFORMED_XML
                                    end
                                else 
                                    raise Exception,MALFORMED_XML
                                end
                            end
                        else 
                            ch = characters::toString()
                            if !(ch == "")
                                @columnNumber -= 2
                                c::characters(ch)
                                @columnNumber += 2
                            end
                            characters = StringBuf.new()
                            if @current == CHAR_INTERROGATION
                                state = HEADER
                            else 
                                if @current == CHAR_BAR
                                    state = TAG_NAME_CLOSE
                                else 
                                    if SAXParser.isValidInitCharacter(@current)
                                        state = TAG_NAME
                                            next
                                    else 
                                        raise Exception,MALFORMED_XML
                                    end
                                end
                            end
                        end
                    else 
                        if state == TAG_NAME
                            sb = StringBuf.new()
                            while SAXParser.isValidCharacter(@current)
                                sb::addChar(@current)
                                nextChar()
                            end
                            tagName = sb::toString()
                            names::push(tagName)
                            if currentIsBlank()
                                state = IGNORE_SPACES
                                nextState = BODY
                            else 
                                if @current == CHAR_BAR
                                    state = BODY
                                        next
                                else 
                                    if @current == CHAR_GREATER_THAN
                                        c::startElement("","",tagName,Attributes.new())
                                        state = CHILDS
                                    else 
                                        raise Exception,MALFORMED_XML
                                    end
                                end
                            end
                        else 
                            if state == TAG_NAME_CLOSE
                                sb = StringBuf.new()
                                while SAXParser.isValidCharacter(@current)
                                    sb::addChar(@current)
                                    nextChar()
                                end
                                tagName = sb::toString()
                                ignoreSpaces()
                                name = names::_(names::length() - 1)
                                if (@current == CHAR_GREATER_THAN) && (tagName == name)
                                    names::pop()
                                    c::endElement("","",tagName)
                                    state = CHILDS
                                else 
                                    raise Exception,("Expected </" + tagName) + ">"
                                end
                            else 
                                if state == IGNORE_SPACES
                                    if !currentIsBlank()
                                        state = nextState
                                            next
                                    end
                                else 
                                    if state == COMMENT
                                        if searchString("-->")
                                            state = nextState
                                        else 
                                            raise Exception,"Comment not closed."
                                        end
                                    else 
                                        if state == BODY
                                            if @current == CHAR_BAR
                                                nextChar()
                                                if @current == CHAR_GREATER_THAN
                                                    tagName = names::pop()
                                                    c::startElement("","",tagName,attribs)
                                                    attribs = Attributes.new()
                                                    c::endElement("","",tagName)
                                                    state = CHILDS
                                                else 
                                                    raise Exception,MALFORMED_XML
                                                end
                                            else 
                                                if @current == CHAR_GREATER_THAN
                                                    c::startElement("","",names::_(names::length() - 1),attribs)
                                                    attribs = Attributes.new()
                                                    state = CHILDS
                                                else 
                                                    if SAXParser.isValidInitCharacter(@current)
                                                        state = ATTRIB
                                                            next
                                                    else 
                                                        raise Exception,MALFORMED_XML
                                                    end
                                                end
                                            end
                                        else 
                                            if state == HEADER
                                                if searchString("?>")
                                                    state = IGNORE_SPACES
                                                    nextState = BEGIN
                                                else 
                                                    raise Exception,MALFORMED_XML
                                                end
                                            else 
                                                if state == ATTRIB
                                                    if searchString("=")
                                                        attribName = Std::substr(@xml,lastIndex,(@index - lastIndex) - 1)
                                                        nextChar()
                                                        ignoreSpaces()
                                                        lastIndex = @index
                                                        if @current == CHAR_DOUBLE_QUOT
                                                            nextChar()
                                                            if !searchString("\"")
                                                                raise Exception,MALFORMED_XML
                                                            end
                                                        else 
                                                            if @current == CHAR_QUOT
                                                                nextChar()
                                                                if !searchString("\'")
                                                                    raise Exception,MALFORMED_XML
                                                                end
                                                            else 
                                                                raise Exception,MALFORMED_XML
                                                            end
                                                        end
                                                        value = Std::substr(@xml,lastIndex,(@index - lastIndex) - 1)
                                                        value = SAXParser.formatLineEnds(value)
                                                        if attribs::getValueFromName(attribName) != nil
                                                            raise Exception,("Attribute " + attribName) + " already used in this tag."
                                                        else 
                                                            attribs::add(attribName,parseEntities(value))
                                                        end
                                                    else 
                                                        raise Exception,MALFORMED_XML
                                                    end
                                                    state = IGNORE_SPACES
                                                    nextState = BODY
                                                else 
                                                    if state == CHILDS
                                                        if searchString("<")
                                                            pcdata = Std::substr(@xml,lastIndex,(@index - lastIndex) - 1)
                                                            parsedPCData = parseEntities(pcdata)
                                                            parsedPCData = SAXParser.formatLineEnds(parsedPCData)
                                                            characters::add(parsedPCData)
                                                            state = BEGIN_NODE
                                                            nextState = CHILDS
                                                        else 
                                                            if @current != -1
                                                                raise Exception,MALFORMED_XML
                                                            end
                                                        end
                                                    else 
                                                        if state == CDATA
                                                            if searchString("]]>")
                                                                cdata = Std::substr(@xml,lastIndex,(@index - lastIndex) - 3)
                                                                cdata = SAXParser.formatLineEnds(cdata)
                                                                characters::add(cdata)
                                                                state = CHILDS
                                                                nextState = BEGIN
                                                            else 
                                                                raise Exception,MALFORMED_XML
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                lastIndex = @index
                nextChar()
            end
            remainder = characters::toString()
            if !(remainder == "")
                c::characters(remainder)
            end
            if names::length() > 0
                raise Exception,MALFORMED_XML
            end
            c::endDocument()
        end
        def self.isValidInitCharacter(c)
            return ((WCharacterBase::isLetter(c) || (c == CHAR_UNDERSCORE)) || (c == CHAR_COLON))
        end
        def self.isValidCharacter(c)
            return (((((WCharacterBase::isLetter(c) || WCharacterBase::isDigit(c)) || (c == CHAR_UNDERSCORE)) || (c == CHAR_HYPHEN)) || (c == CHAR_DOT)) || (c == CHAR_COLON))
        end
        def parseEntities(pcdata)
            if (pcdata == nil) || (pcdata == "")
                return ""
            end
            in1 = pcdata::indexOf("&")
            if in1 == -1
                return pcdata
            end
            in2 = pcdata::indexOf(";",in1)
            parsed = StringBuf.new()
            parsed::add(Std::substr(pcdata,0,in1))
            while ((in2 != -1) && (in1 < pcdata::length())) && (in2 < pcdata::length())
                in1+=1
                entity = Std::substr(pcdata,in1,in2 - in1)
                in2+=1
                if (entity == "quot")
                    parsed::add("\"")
                else 
                    if (entity == "lt")
                        parsed::add("<")
                    else 
                        if (entity == "gt")
                            parsed::add(">")
                        else 
                            if (entity == "apos")
                                parsed::add("\'")
                            else 
                                if (entity == "amp")
                                    parsed::add("&")
                                else 
                                    if Std::charCodeAt(entity,0) == CHAR_HASH
                                        utfvalue = 0
                                        if Std::charCodeAt(entity,1) == CHAR_X
                                            value = Std::substr(entity,2)
                                            utfvalue = Std::parseInt("0x" + value)
                                        else 
                                            value = Std::substr(entity,1)
                                            utfvalue = Std::parseInt(value)
                                        end
                                        if utfvalue == 0
                                            raise Exception,"Invalid numeric entity."
                                        end
                                        newvalue = Utf8::uchr(utfvalue)
                                        parsed::add(newvalue)
                                    else 
                                        r = 0
                                        sol = -1
                                        while (r < @entityResolvers::length()) && (sol == -1)
                                            sol = @entityResolvers::_(r)::resolveEntity(entity)
                                            r+=1
                                        end
                                        if sol != -1
                                            parsed::add(Utf8::uchr(sol))
                                        else 
                                            parsed::add(("&" + entity) + ";")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                in1 = pcdata::indexOf('&',in2)
                if in1 == -1
                    parsed::add(Std::substr(pcdata,in2))
                    in2 = pcdata::length()
                else 
                    parsed::add(Std::substr(pcdata,in2,in1 - in2))
                    in2 = pcdata::indexOf(';',in1)
                end
            end
            return parsed::toString()
        end
        def nextChar()
            if iterator::hasNext()
                @last = @current
                @current = iterator::next()
                @index += (Utf8::uchr(@current))::length()
                if (@last == CHAR_LINE_FEED) || ((@last == CHAR_CARRIAGE_RETURN) && (@current != CHAR_LINE_FEED))
                    @columnNumber = 1
                    @lineNumber+=1
                else 
                    @columnNumber+=1
                end
            else 
                @current = -1
            end
        end
        def searchString(search)
            n = search::length()
            if n == 0
                return true
            end
            i = 0
            while @current != -1
                if @current == Utf8::charCodeAt(search,i)
                    i+=1
                    if i == n
                        return true
                    end
                else 
                    while i > 0
                        if @current == Utf8::charCodeAt(search,i - 1)
                            j = i - 1
                            while j > 1
                                if Utf8::charCodeAt(search,j) != Utf8::charCodeAt(search,j - 1)
                                    i-=1
                                    break
                                end
                                j-=1
                            end
                            break
                        else 
                            i-=1
                        end
                    end
                end
                nextChar()
            end
            return false
        end
        def self.formatLineEnds(data)
            if (data == "")
                return data
            end
            sb = StringBuf.new()
            it = Utf8::getIterator(data)
            carriageReturn = false
            while it::hasNext()
                c = it::next()
                if c == CHAR_CARRIAGE_RETURN
                    carriageReturn = true
                    sb::addChar(CHAR_LINE_FEED)
                else 
                    if carriageReturn
                        carriageReturn = false
                        if c != CHAR_LINE_FEED
                            sb::addChar(c)
                        end
                    else 
                        sb::addChar(c)
                    end
                end
            end
            return sb::toString()
        end
        def currentIsBlank()
            return ((((@current == CHAR_SPACE) || (@current == CHAR_LINE_FEED)) || (@current == CHAR_CARRIAGE_RETURN)) || (@current == CHAR_TAB))
        end
        def ignoreSpaces()
            while currentIsBlank()
                nextChar()
            end
        end

    end
end
