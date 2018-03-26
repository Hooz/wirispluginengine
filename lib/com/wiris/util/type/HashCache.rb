module WirisPlugin
include  Wiris
    class HashCache < HashT
    include Wiris

        attr_accessor :maxSize
        attr_accessor :sortedKeys
        def initialize(maxSize)
            super()
            @maxSize = maxSize
            @sortedKeys = Array.new()
        end
        def getMaxSize()
            return @maxSize
        end
        def setMaxSize(maxSize)
            @maxSize = maxSize
        end
        def getSortedKeys()
            return @sortedKeys
        end
        def remove(key)
            if sortedKeys::remove(key)
                return super(key)
            end
            return false
        end
        def keys()
            return sortedKeys::iterator()
        end
        def set(key, value)
            if (@sortedKeys != nil) && (sortedKeys::length() >= @maxSize)
                removed = sortedKeys::_(0)
                if sortedKeys::remove(removed)
                    super(removed)
                end
            end
            sortedKeys::push(key)
            super(key,value)
        end

    end
end
