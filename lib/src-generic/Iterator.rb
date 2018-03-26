module Wiris
    class Iterator < Enumerator
        @enumeration
        def initialize(enum)
            @enumeration = enum.map
        end

        def next
            @enumeration.next
        end

        def hasNext()
            begin
                @enumeration.peek
                return true
            rescue StopIteration
                return false
            end
        end
    end
end