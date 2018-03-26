module WirisPlugin
include  Wiris
    require('com/wiris/util/json/JSon.rb')
    class JsonAPIResponse
    include Wiris

    STATUS_OK = 0
    STATUS_WARNING = 1
    STATUS_ERROR = -1
        def initialize()
            super()
            @result = Hash.new()
            @errors = Array.new()
            @warnings = Array.new()
        end
        attr_accessor :status
        attr_accessor :result
        attr_accessor :errors
        attr_accessor :warnings
        def getResponse()
            response = Hash.new()
            if @status == STATUS_ERROR
                response::set("errors",@errors)
                response::set("status","error")
            end
            if @status == STATUS_WARNING
                response::set("warnings",@warnings)
                response::set("result",@result)
                response::set("status","warning")
            end
            if @status == STATUS_OK
                response::set("result",@result)
                response::set("status","ok")
            end
            return JSon::encode(response)
        end
        def addResult(key, value)
            result::set(key,value)
        end
        def setResult(obj)
            @result = obj
        end
        def getResult()
            if @status == STATUS_ERROR
                return nil
            else 
                return @result
            end
        end
        def addWarning(warning)
            warnings::push(warning)
        end
        def addError(error)
            errors::push(error)
        end
        def setStatus(status)
            if ((status != STATUS_OK) && (status != STATUS_WARNING)) && (status != STATUS_ERROR)
                raise Exception,"Invalid status code"
            end
            @status = status
        end
        def getStatus()
            return @status
        end
        def toString()
            return getResponse()
        end

    end
end
