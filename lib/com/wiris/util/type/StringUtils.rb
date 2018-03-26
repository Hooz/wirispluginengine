module WirisPlugin
include  Wiris
    require('com/wiris/util/xml/WCharacterBase.rb')
    class StringUtils
    include Wiris

        def initialize()
            super()
        end
        def self.stripAccents(s)
            sb = StringBuf.new()
            i = Utf8::getIterator(s)
            while i::hasNext()
                sb::add(WCharacterBase::stripAccent(i::next()))
            end
            return sb::toString()
        end
        def self.compareIgnoringAccents(a, b)
            return (StringUtils::stripAccents(a) == StringUtils::stripAccents(b))
        end

    end
end
