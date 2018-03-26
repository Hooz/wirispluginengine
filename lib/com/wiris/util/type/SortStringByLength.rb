module WirisPlugin
include  Wiris
    require('com/wiris/util/type/Arrays.rb')
    class SortStringByLength
    extend Comparator<String>Interface

    include Wiris

        attr_accessor :arrayToSort
        def initialize(arrayToSort)
            super()
            @arrayToSort = arrayToSort
            Arrays::sort(@arrayToSort,self)
        end
        def getSorted()
            return @arrayToSort
        end
        def compare(a, b)
            if a::length() < b::length()
                return 1
            end
            return -1
        end

    end
end
