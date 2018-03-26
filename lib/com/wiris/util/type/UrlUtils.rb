module WirisPlugin
include  Wiris
    class UrlUtils
    include Wiris

        def initialize()
            super()
        end
    @@charCodeA;
        def self.charCodeA
            @@charCodeA
        end
        def self.charCodeA=(charCodeA)
            @@charCodeA = charCodeA
        end
    @@charCodeZ;
        def self.charCodeZ
            @@charCodeZ
        end
        def self.charCodeZ=(charCodeZ)
            @@charCodeZ = charCodeZ
        end
    @@charCodea;
        def self.charCodea
            @@charCodea
        end
        def self.charCodea=(charCodea)
            @@charCodea = charCodea
        end
    @@charCodez;
        def self.charCodez
            @@charCodez
        end
        def self.charCodez=(charCodez)
            @@charCodez = charCodez
        end
    @@charCode0;
        def self.charCode0
            @@charCode0
        end
        def self.charCode0=(charCode0)
            @@charCode0 = charCode0
        end
    @@charCode9;
        def self.charCode9
            @@charCode9
        end
        def self.charCode9=(charCode9)
            @@charCode9 = charCode9
        end
        def self.isAllowed(c)
            allowedChars = "-_.!~*\'()"::indexOf(Std::fromCharCode(c)) != -1
            return ((((c >= @@charCodeA) && (c <= @@charCodeZ)) || ((c >= @@charCodea) && (c <= @@charCodez))) || ((c >= @@charCode0) && (c <= @@charCode9))) || allowedChars
        end
        def self.urlComponentEncode(uriComponent)
            sb = StringBuf.new()
            buf = Bytes::ofData(Utf8::toBytes(uriComponent))
            for i in 0..buf::length() - 1
                b = buf::get(i)&255
                if UrlUtils.isAllowed(b)
                    sb::add(Std::fromCharCode(b))
                else 
                    sb::add("%")
                    sb::add(StringTools::hex(b,2))
                end
                i+=1
            end
            return sb::toString()
        end

    @@charCodeA = Std::charCodeAt("A",0)
    @@charCodeZ = Std::charCodeAt("Z",0)
    @@charCodea = Std::charCodeAt("a",0)
    @@charCodez = Std::charCodeAt("z",0)
    @@charCode0 = Std::charCodeAt("0",0)
    @@charCode9 = Std::charCodeAt("9",0)
    end
end
