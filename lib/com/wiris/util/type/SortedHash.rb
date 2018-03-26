module WirisPlugin
include  Wiris
    require('com/wiris/util/type/Arrays.rb')
    class SortedHash < HashT
    include Wiris

        attr_accessor :sortedKeys
        def initialize()
            super()
            @sortedKeys = Array.new()
        end
        def set(key, value)
            i = Arrays::indexOfElement(@sortedKeys,key)
            if i >= 0
                sortedKeys::_(i,key)
            else 
                sortedKeys::push(key)
            end
            super(key,value)
        end
        def remove(key)
            sortedKeys::remove(key)
            return super(key)
        end
        def keys()
            return sortedKeys::iterator()
        end
        def getSortedKeys()
            return @sortedKeys
        end
        def push(key, value, limit)
            idx = Arrays::indexOfElement(@sortedKeys,key)
            if idx >= 0
                sortedKeys::splice(idx,1)
                sortedKeys::push(key)
            else 
                if (limit >= 0) && (sortedKeys::length() >= limit)
                    sortedKeys::splice(0,1)
                end
                set(key,value)
            end
        end

    end
end
