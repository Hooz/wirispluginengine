module WirisPlugin
include  Wiris
    require('com/wiris/plugin/api/ConfigurationKeys.rb')
    require('com/wiris/plugin/impl/CustomConfigurationUpdater.rb')
    require('com/wiris/plugin/api/Configuration.rb')
    require('com/wiris/util/json/JSon.rb')
    require('com/wiris/plugin/impl/FileConfigurationUpdater.rb')
    require('com/wiris/plugin/api/Configuration.rb')
    class ConfigurationImpl
    extend ConfigurationInterface

    include Wiris

        attr_accessor :plugin
        attr_accessor :initObject
        attr_accessor :props
        attr_accessor :initialized
        def initialize()
            super()
            @props = PropertiesTools::newProperties()
        end
        def getFullConfiguration()
            initialize0()
            return @props
        end
        def getProperty(key, dflt)
            initialize0()
            return PropertiesTools::getProperty(@props,key,dflt)
        end
        def setProperty(key, value)
            PropertiesTools::setProperty(@props,key,value)
        end
        def setInitObject(context)
            @initObject = context
        end
        def initialize0()
            if @initialized
                return 
            end
            @initialized = true
            @plugin::addConfigurationUpdater(FileConfigurationUpdater.new())
            @plugin::addConfigurationUpdater(CustomConfigurationUpdater.new(self))
            a = @plugin::getConfigurationUpdaterChain()
            iter = a::iterator()
            while iter::hasNext()
                cu = iter::next()
                initialize_(cu)
                cu::updateConfiguration(@props)
            end
        end
        def initialize_(cu)
            cu::init(@initObject)
        end
        def setPluginBuilderImpl(plugin)
            @plugin = plugin
        end
        def appendVarJs(sb, varName, value, comment)
            sb::add("var ")
            sb::add(varName)
            sb::add(" = ")
            sb::add(value)
            sb::add(";")
            if (comment != nil) && (comment::length() > 0)
                sb::add("// ")
                sb::add(comment)
            end
            sb::add("\r\n")
        end
        def appendElement2JavascriptArray(array, value)
            arrayOpen = array::indexOf("[")
            arrayClose = array::indexOf("]")
            if (arrayOpen == -1) || (arrayClose == -1)
                raise Exception,"Array not valid"
            end
            return ((("[" + "\'") + value) + "\'") + (array::length() == 2 ? "]" : "," + Std::substr(array,arrayOpen + 1,arrayClose - arrayOpen).to_s)
        end
        def getJavaScriptHash()
            javaScriptHash = Hash.new()
            javaScriptHash::set("_wrs_conf_editorEnabled",Boolean::valueOf((getProperty("wiriseditorenabled",nil) == "true")))
            javaScriptHash::set("_wrs_conf_imageMathmlAttribute",getProperty("wiriseditormathmlattribute",nil))
            javaScriptHash::set("_wrs_conf_saveMode",getProperty("wiriseditorsavemode",nil))
            javaScriptHash::set("_wrs_conf_editMode",getProperty("wiriseditoreditmode",nil))
            parseLatexElements = Array.new()
            if (getProperty("wiriseditorparselatex",nil) == "true")
                parseLatexElements::push("latex")
            end
            if (getProperty("wiriseditorparsexml",nil) == "true")
                parseLatexElements::push("xml")
            end
            javaScriptHash::set("_wrs_conf_parseModes",parseLatexElements)
            javaScriptHash::set("_wrs_conf_editorAttributes",getProperty("wiriseditorwindowattributes",nil))
            javaScriptHash::set("_wrs_conf_editorUrl",@plugin::getImageServiceURL("editor",false))
            javaScriptHash::set("_wrs_conf_modalWindow",Boolean::valueOf((getProperty("wiriseditormodalwindow",nil) == "true")))
            javaScriptHash::set("_wrs_conf_modalWindowFullScreen",Boolean::valueOf((getProperty("wiriseditormodalwindowfullscreen",nil) == "true")))
            javaScriptHash::set("_wrs_conf_CASEnabled",Boolean::valueOf((getProperty("wiriscasenabled",nil) == "true")))
            javaScriptHash::set("_wrs_conf_CASMathmlAttribute",getProperty("wiriscasmathmlattribute",nil))
            javaScriptHash::set("_wrs_conf_CASAttributes",getProperty("wiriscaswindowattributes",nil))
            javaScriptHash::set("_wrs_conf_hostPlatform",getProperty("wirishostplatform",nil))
            javaScriptHash::set("_wrs_conf_versionPlatform",getProperty("wirisversionplatform","unknown"))
            javaScriptHash::set("_wrs_conf_enableAccessibility",Boolean::valueOf((getProperty("wirisaccessibilityenabled",nil) == "true")))
            javaScriptHash::set("_wrs_conf_setSize",Boolean::valueOf((getProperty("wiriseditorsetsize","false") == "true")))
            javaScriptHash::set("_wrs_conf_editorToolbar",getProperty(ConfigurationKeys::EDITOR_TOOLBAR,nil))
            javaScriptHash::set("_wrs_conf_chemEnabled",Boolean::valueOf((getProperty("wirischemeditorenabled",nil) == "true")))
            javaScriptHash::set("_wrs_conf_imageFormat",getProperty("wirisimageformat","png"))
            if getProperty(ConfigurationKeys::EDITOR_PARAMS,nil) != nil
                javaScriptHash::set("_wrs_conf_editorParameters",JSon::decode(getProperty(ConfigurationKeys::EDITOR_PARAMS,nil)))
            else 
                h = ConfigurationKeys::imageConfigPropertiesInv
                attributes = Hash.new()
                confVal = ""
                i = 0
                it = h::keys()
                while it::hasNext()
                    value = it::next()
                    if getProperty(value,nil) != nil
                        confVal = getProperty(value,nil)
                        StringTools::replace(confVal,"-","_")
                        StringTools::replace(confVal,"-","_")
                        attributes::set(confVal,value)
                    end
                end
                javaScriptHash::set("_wrs_conf_editorParameters",attributes)
            end
            javaScriptHash::set("_wrs_conf_wirisPluginPerformance",Boolean::valueOf((getProperty("wirispluginperformance",nil) == "true")))
            begin
            version = Storage::newResourceStorage("VERSION")::read()
            if version == nil
                version = "Missing version"
            end
            end
            javaScriptHash::set("_wrs_conf_version",version)
            return javaScriptHash
        end
        def getJavaScriptConfigurationJson()
            javaScriptHash = getJavaScriptHash()
            return JSon::encode(javaScriptHash)
        end
        def getJsonConfiguration(configurationKeys)
            configurationKeysArray = Std::split(configurationKeys,",")
            iterator = configurationKeysArray::iterator()
            jsonOutput = Hash.new()
            jsonVariables = Hash.new()
            thereIsNullValue = false
            while iterator::hasNext()
                key = iterator::next()
                value = getProperty(key,"null")
                if (value == "null")
                    thereIsNullValue = true
                end
                jsonVariables::set(key,value)
            end
            if !thereIsNullValue
                jsonOutput::set("status","ok")
            else 
                jsonOutput::set("status","warning")
            end
            jsonOutput::set("result",jsonVariables)
            return JSon::encode(jsonOutput)
        end
        def setConfigurations(configurationKeys, configurationValues)
            configurationKeysArray = Std::split(configurationKeys,",")
            configurationValuesArray = Std::split(configurationValues,",")
            keysIterator = configurationKeysArray::iterator()
            valuesIterator = configurationValuesArray::iterator()
            while keysIterator::hasNext() && valuesIterator::hasNext()
                key = keysIterator::next()
                value = valuesIterator::next()
                if getProperty(key,nil) != nil
                    setProperty(key,value)
                end
            end
        end

    end
end
