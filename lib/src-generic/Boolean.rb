module Wiris
    class Boolean

        @boolean
        def boolean=(boolean)
        @boolean=boolean
        end
        def boolean
            @boolean
        end
        def initialize(boolean)
            @boolean = boolean
        end

        def self.valueOf(boolean)
            return Boolean.new(boolean)
        end

        def booleanValue()
            return boolean
        end


    end
end


