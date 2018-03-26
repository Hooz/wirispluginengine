module WirisPlugin
include  Wiris
    class Tokenizer
    include Wiris

        attr_accessor :delimiters
        attr_accessor :takeDelimiters
        def initialize(delimiters, takeDelimiters)
            super()
            @delimiters = delimiters
            @takeDelimiters = takeDelimiters
        end
        def getDelimiters()
            return @delimiters
        end
        def splitTokens(text)
            tokens = Array.new()
            it = Utf8::getIterator(text)
            block = StringBuf.new()
            while it::hasNext()
                c = Utf8::uchr(it::next())
                if delimiters::indexOf(c) >= 0
                    tokens::push(block::toString())
                    if @takeDelimiters
                        tokens::push(c)
                    end
                    block = StringBuf.new()
                else 
                    block::add(c)
                end
            end
            last = block::toString()
            if !(last == "")
                tokens::push(last)
            end
            return tokens
        end

    end
end
