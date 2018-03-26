module WirisPlugin
include  Wiris
    class IntegerTools
    include Wiris

        def initialize()
            super()
        end
        def self.max(x, y)
            return (x > y) ? x : y
        end
        def self.min(x, y)
            return (x < y) ? x : y
        end
        def self.clamp(x, a, b)
            return IntegerTools.min(IntegerTools.max(a,x),b)
        end
        def self.isInt(x)
            return (EReg.new("[\\+\\-]?\\d+",""))::match(x)
        end

    end
end
