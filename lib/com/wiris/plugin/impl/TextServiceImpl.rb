module WirisPlugin
include  Wiris
    require('com/wiris/util/json/JsonAPIResponse.rb')
    require('com/wiris/plugin/impl/HttpImpl.rb')
    require('com/wiris/plugin/impl/HttpListener.rb')
    require('com/wiris/util/sys/IniFile.rb')
    require('com/wiris/plugin/api/TextService.rb')
    require('com/wiris/plugin/impl/TextFilter.rb')
    require('com/wiris/util/json/JSon.rb')
    class TextServiceImpl
    extend TextServiceInterface

    extend HttpListenerInterface

    include Wiris

        attr_accessor :plugin
        attr_accessor :serviceName
        attr_accessor :status
        attr_accessor :error
        attr_accessor :data
        def initialize(plugin)
            super()
            @plugin = plugin
        end
        def service(serviceName, provider)
            @serviceName = serviceName
            digest = nil
            renderParams = provider::getRenderParameters(@plugin::getConfiguration())
            if TextServiceImpl.hasCache(serviceName)
                digest = @plugin::newRender()::computeDigest(nil,renderParams)
                store = @plugin::getStorageAndCache()
                ext = TextServiceImpl.getDigestExtension(serviceName,provider)
                s = store::retreiveData(digest,ext)
                if s != nil
                    cachedServiceText = Utf8::fromBytes(s)
                    begin
                    JSon::decode(cachedServiceText)
                    end
                    return cachedServiceText
                end
            end
            return jsonResponse(serviceName,provider)::getResponse()
        end
        def jsonResponse(serviceName, provider)
            renderParams = provider::getRenderParameters(@plugin::getConfiguration())
            digest = @plugin::newRender()::computeDigest(nil,renderParams)
            @serviceName = serviceName
            url = @plugin::getImageServiceURL(serviceName,TextServiceImpl.hasStats(serviceName))
            h = HttpImpl.new(url,self)
            @plugin::addReferer(h)
            @plugin::addProxy(h)
            ha = PropertiesTools::fromProperties(provider::getServiceParameters())
            iter = ha::keys()
            while iter::hasNext()
                k = iter::next()
                h::setParameter(k,ha::get(k))
            end
            h::setParameter("httpstatus","true")
            begin
            h::request(true)
            end
            r = @data != nil ? @data : h::getData()
            response = JsonAPIResponse.new()
            if @status == JsonAPIResponse::STATUS_ERROR
                response::setStatus(JsonAPIResponse::STATUS_ERROR)
                response::addError(@error)
            else 
                response::setStatus(JsonAPIResponse::STATUS_OK)
                response::addResult("text",r)
            end
            if digest != nil
                store = @plugin::getStorageAndCache()
                ext = TextServiceImpl.getDigestExtension(serviceName,provider)
                store::storeData(digest,ext,Utf8::toBytes(response::getResponse()))
            end
            return response
        end
        def mathml2accessible(mml, lang, param)
            if lang != nil
                PropertiesTools::setProperty(param,"lang",lang)
            end
            PropertiesTools::setProperty(param,"mml",mml)
            provider = @plugin::newGenericParamsProvider(param)
            reponse = jsonResponse("mathml2accessible",provider)
            if reponse::getStatus() == JsonAPIResponse::STATUS_OK
                result = reponse::getResult()
                return (result::get("text"))
            else 
                return "Error converting from mathml to text"
            end
        end
        def mathml2latex(mml)
            param = PropertiesTools::newProperties()
            PropertiesTools::setProperty(param,"mml",mml)
            provider = @plugin::newGenericParamsProvider(param)
            return service("mathml2latex",provider)
        end
        def latex2mathml(latex)
            param = PropertiesTools::newProperties()
            PropertiesTools::setProperty(param,"latex",latex)
            provider = @plugin::newGenericParamsProvider(param)
            mathml = service("latex2mathml",provider)
            return mathml::indexOf("Error converting") != -1 ? mathml : latex
        end
        def getMathML(digest, latex)
            if digest != nil
                content = @plugin::getStorageAndCache()::decodeDigest(digest)
                if content != nil
                    if StringTools::startsWith(content,"<")
                        breakline = content::indexOf("\n",0)
                        return Std::substr(content,0,breakline)
                    else 
                        iniFile = IniFile::newIniFileFromString(content)
                        mathml = iniFile::getProperties()::get("mml")
                        if mathml != nil
                            return mathml
                        else 
                            return "Error: mathml not found."
                        end
                    end
                else 
                    return "Error: formula not found."
                end
            else 
                if latex != nil
                    return latex2mathml(latex)
                else 
                    return "Error: no digest or latex has been sent."
                end
            end
        end
        def self.hasCache(serviceName)
            if (serviceName == "mathml2accessible")
                return true
            end
            return false
        end
        def self.hasStats(serviceName)
            if (serviceName == "latex2mathml")
                return true
            end
            return false
        end
        def self.getDigestExtension(serviceName, provider)
            lang = provider::getParameter("lang","en")
            if (lang != nil) && (lang::length() == 0)
                return "en"
            end
            return lang
        end
        def filter(str, prop)
            return TextFilter.new(@plugin)::filter(str,prop)
        end
        def onData(msg)
            @status = JsonAPIResponse::STATUS_OK
        end
        def onError(msg)
            if @serviceName == "mathml2accessible"
                @status = JsonAPIResponse::STATUS_WARNING
                @data = "Error converting from MathML to accessible text."
            else 
                @error = msg
                @status = JsonAPIResponse::STATUS_ERROR
            end
        end

    end
end
