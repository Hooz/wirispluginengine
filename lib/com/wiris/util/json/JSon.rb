module WirisPlugin
include  Wiris
    require('com/wiris/util/json/StringParser.rb')
    require('com/wiris/util/xml/WCharacterBase.rb')
    require('com/wiris/util/json/JSonIntegerFormat.rb')
    require('com/wiris/common/WInteger.rb')
    require('com/wiris/util/json/StringParser.rb')
    class JSon < StringParser
    include Wiris

        def self.sb
            @@sb
        end
        def self.sb=(sb)
            @@sb = sb
        end
        attr_accessor :addNewLines
        attr_accessor :depth
        attr_accessor :lastDepth
        def initialize()
            super()
        end
        def self.encode(o)
            js = JSon.new()
            return js::encodeObject(o)
        end
        def encodeObject(o)
            sb = StringBuf.new()
            @depth = 0
            encodeImpl(sb,o)
            return sb::toString()
        end
        def encodeImpl(sb, o)
            if TypeTools::isHash(o)
                encodeHash(sb,(o))
            else 
                if TypeTools::isArray(o)
                    encodeArray(sb,(o))
                else 
                    if o.instance_of?Array
                        encodeArrayInt(sb,(o))
                    else 
                        if o.instance_of?String
                            encodeString(sb,(o))
                        else 
                            if o.instance_of?Integer
                                encodeInteger(sb,(o))
                            else 
                                if o.instance_of?Bignum
                                    encodeLong(sb,(o))
                                else 
                                    if o.instance_of?JSonIntegerFormat
                                        encodeIntegerFormat(sb,(o))
                                    else 
                                        if o.instance_of?Boolean
                                            encodeBoolean(sb,(o))
                                        else 
                                            if o.instance_of?Double
                                                encodeFloat(sb,(o))
                                            else 
                                                raise Exception,"Impossible to convert to json object of type " + Type::getClass(o).to_s
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
        def encodeHash(sb, h)
            newLines = @addNewLines && (JSon.getDepth(h) > 2)
            @depth+=1
            myDepth = @lastDepth
            sb::add("{")
            if newLines
                newLine(@depth,sb)
            end
            e = h::keys()
            first = true
            while e::hasNext()
                if first
                    first = false
                else 
                    sb::add(",")
                    if newLines
                        newLine(@depth,sb)
                    end
                end
                key = e::next()
                encodeString(sb,key)
                sb::add(":")
                encodeImpl(sb,h::get(key))
            end
            if newLines
                newLine(myDepth,sb)
            end
            sb::add("}")
            @depth-=1
        end
        def encodeArray(sb, v)
            newLines = @addNewLines && (JSon.getDepth(v) > 2)
            @depth+=1
            myDepth = @lastDepth
            sb::add("[")
            if newLines
                newLine(@depth,sb)
            end
            for i in 0..v::length() - 1
                o = v::_(i)
                if i > 0
                    sb::add(",")
                    if newLines
                        newLine(@depth,sb)
                    end
                end
                encodeImpl(sb,o)
                i+=1
            end
            if newLines
                newLine(myDepth,sb)
            end
            sb::add("]")
            @depth-=1
        end
        def encodeArrayInt(sb, v)
            v2 = Array.new()
            i = 0
            while i < v::length
                v2::push(v[i])
                i+=1
            end
            encodeArray(sb,v2)
        end
        def encodeString(sb, s)
            s = StringTools::replace(s,"\\","\\\\")
            s = StringTools::replace(s,"\"","\\\"")
            s = StringTools::replace(s,"\r","\\r")
            s = StringTools::replace(s,"\n","\\n")
            s = StringTools::replace(s,"\t","\\t")
            sb::add("\"")
            sb::add(s)
            sb::add("\"")
        end
        def encodeInteger(sb, i)
            sb::add("" + i.to_s)
        end
        def encodeBoolean(sb, b)
            sb::add(b::booleanValue() ? "true" : "false")
        end
        def encodeFloat(sb, d)
            sb::add(TypeTools::floatToString(d))
        end
        def encodeLong(sb, i)
            sb::add("" + i.to_s)
        end
        def encodeIntegerFormat(sb, i)
            sb::add(i::toString())
        end
        def self.decode(str)
            json = JSon.new()
            return json::localDecodeString(str)
        end
        def localDecodeString(str)
            init(str)
            return localDecode()
        end
        def localDecode()
            skipBlanks()
            if c == 123
                return decodeHash()
            else 
                if c == 91
                    return decodeArray()
                else 
                    if c == 34
                        return decodeString()
                    else 
                        if c == 39
                            return decodeString()
                        else 
                            if (c == 45) || ((c >= 48) && (c <= 58))
                                return decodeNumber()
                            else 
                                if ((c == 116) || (c == 102)) || (c == 110)
                                    return decodeBooleanOrNull()
                                else 
                                    raise Exception,"Unrecognized char " + c.to_s
                                end
                            end
                        end
                    end
                end
            end
        end
        def decodeBooleanOrNull()
            sb = StringBuf.new()
            while WCharacterBase::isLetter(c)
                sb::addChar(c)
                nextToken()
            end
            word = sb::toString()
            if (word == "true")
                return Boolean::TRUE
            else 
                if (word == "false")
                    return Boolean::FALSE
                else 
                    if (word == "null")
                        return nil
                    else 
                        raise Exception,("Unrecognized keyword \"" + word) + "\"."
                    end
                end
            end
        end
        def decodeString()
            sb = StringBuf.new()
            d = c
            nextToken()
            while c != d
                if c == 92
                    nextToken()
                    if c == 110
                        sb::add("\n")
                    else 
                        if c == 114
                            sb::add("\r")
                        else 
                            if c == 34
                                sb::add("\"")
                            else 
                                if c == 39
                                    sb::add("\'")
                                else 
                                    if c == 116
                                        sb::add("\t")
                                    else 
                                        if c == 92
                                            sb::add("\\")
                                        else 
                                            if c == 117
                                                nextToken()
                                                code = Utf8::uchr(c)
                                                nextToken()
                                                code += Utf8::uchr(c)
                                                nextToken()
                                                code += Utf8::uchr(c)
                                                nextToken()
                                                code += Utf8::uchr(c)
                                                dec = Std::parseInt("0x" + code)
                                                sb::add(Utf8::uchr(dec))
                                            else 
                                                raise Exception,("Unknown scape sequence \'\\" + Utf8::uchr(c).to_s) + "\'"
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                else 
                    sb::add(Std::fromCharCode(c))
                end
                nextToken()
            end
            nextToken()
            return sb::toString()
        end
        def decodeNumber()
            sb = StringBuf.new()
            hex = false
            floating = false
            loop do
                sb::add(Std::fromCharCode(c))
                nextToken()
                if c == 120
                    hex = true
                    sb::add(Std::fromCharCode(c))
                    nextToken()
                end
                if ((c == 46) || (c == 69)) || (c == 101)
                    floating = true
                end
            break if not (((c >= 48) && (c <= 58)) || (hex && JSon.isHexDigit(c))) || (floating && ((((c == 46) || (c == 69)) || (c == 101)) || (c == 45)))
            end
            if floating
                return Std::parseFloat(sb::toString())
            else 
                return Std::parseInt(sb::toString())
            end
        end
        def decodeHash()
            h = Hash.new()
            nextToken()
            skipBlanks()
            if c == 125
                nextToken()
                return h
            end
            while c != 125
                key = decodeString()
                skipBlanks()
                if c != 58
                    raise Exception,"Expected \':\'."
                end
                nextToken()
                skipBlanks()
                o = localDecode()
                h::set(key,o)
                skipBlanks()
                if c == 44
                    nextToken()
                    skipBlanks()
                else 
                    if c != 125
                        raise Exception,"Expected \',\' or \'}\'. " + getPositionRepresentation()
                    end
                end
            end
            nextToken()
            return h
        end
        def decodeArray()
            v = Array.new()
            nextToken()
            skipBlanks()
            if c == 93
                nextToken()
                return v
            end
            while c != 93
                o = localDecode()
                v::push(o)
                skipBlanks()
                if c == 44
                    nextToken()
                    skipBlanks()
                else 
                    if c != 93
                        raise Exception,"Expected \',\' or \']\'."
                    end
                end
            end
            nextToken()
            return v
        end
        def self.getDepth(o)
            if TypeTools::isHash(o)
                h = (o)
                m = 0
                if h::exists("_left_") || h::exists("_right_")
                    if h::exists("_left_")
                        m = WInteger::max(JSon.getDepth(h::get("_left_")),m)
                    end
                    if h::exists("_right_")
                        m = WInteger::max(JSon.getDepth(h::get("_right_")),m)
                    end
                    return m
                end
                iter = h::keys()
                while iter::hasNext()
                    key = iter::next()
                    m = WInteger::max(JSon.getDepth(h::get(key)),m)
                end
                return m + 2
            else 
                if TypeTools::isArray(o)
                    a = (o)
                    m = 0
                    for i in 0..a::length() - 1
                        m = WInteger::max(JSon.getDepth(a::_(i)),m)
                        i+=1
                    end
                    return m + 1
                else 
                    return 1
                end
            end
        end
        def setAddNewLines(addNewLines)
            @addNewLines = addNewLines
        end
        def newLine(depth, sb)
            sb::add("\r\n")
            for i in 0..depth - 1
                sb::add("  ")
                i+=1
            end
            @lastDepth = depth
        end
        def self.getString(o)
            return (o)
        end
        def self.getFloat(n)
            if n.instance_of?Double
                return (n)
            else 
                if n.instance_of?Integer
                    return (n) + 0.0
                else 
                    return 0.0
                end
            end
        end
        def self.getInt(n)
            if n.instance_of?Double
                return (Math::round((n)))
            else 
                if n.instance_of?Integer
                    return (n)
                else 
                    return 0
                end
            end
        end
        def self.getBoolean(b)
            return ((b))::booleanValue()
        end
        def self.getArray(a)
            return (a)
        end
        def self.getHash(a)
            return (a)
        end
        def self.compare(a, b, eps)
            if TypeTools::isHash(a)
                isBHash = TypeTools::isHash(b)
                if !isBHash
                    return false
                end
                ha = (a)
                hb = (b)
                it = ha::keys()
                itb = hb::keys()
                while it::hasNext()
                    if !itb::hasNext()
                        return false
                    end
                    itb::next()
                    key = it::next()
                    if !hb::exists(key) || !JSon.compare(ha::get(key),hb::get(key),eps)
                        return false
                    end
                end
                if itb::hasNext()
                    return false
                end
                return true
            else 
                if TypeTools::isArray(a)
                    isBArray = TypeTools::isArray(b)
                    if !isBArray
                        return false
                    end
                    aa = (a)
                    ab = (b)
                    if aa::length() != ab::length()
                        return false
                    end
                    for i in 0..aa::length() - 1
                        if !JSon.compare(aa::_(i),ab::_(i),eps)
                            return false
                        end
                        i+=1
                    end
                    return true
                else 
                    if a.instance_of?String
                        if !(b.instance_of?String)
                            return false
                        end
                        return (a == b)
                    else 
                        if a.instance_of?Integer
                            if !(b.instance_of?Integer)
                                return false
                            end
                            return (a == b)
                        else 
                            if a.instance_of?Bignum
                                isBLong = b.instance_of?Bignum
                                if !isBLong
                                    return false
                                end
                                return (a == b)
                            else 
                                if a.instance_of?JSonIntegerFormat
                                    if !(b.instance_of?JSonIntegerFormat)
                                        return false
                                    end
                                    ja = (a)
                                    jb = (b)
                                    return (ja::toString() == jb::toString())
                                else 
                                    if a.instance_of?Boolean
                                        if !(b.instance_of?Boolean)
                                            return false
                                        end
                                        return (a == b)
                                    else 
                                        if a.instance_of?Double
                                            if !(b.instance_of?Double)
                                                return false
                                            end
                                            da = JSon.getFloat(a)
                                            db = JSon.getFloat(b)
                                            return (da >= (db - eps)) && (da <= (db + eps))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return true
        end

    end
end
