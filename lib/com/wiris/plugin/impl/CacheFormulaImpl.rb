module WirisPlugin
include  Wiris
    require('com/wiris/plugin/api/ConfigurationKeys.rb')
    require('com/wiris/plugin/impl/CacheImpl.rb')
    require('com/wiris/plugin/impl/CacheImpl.rb')
    class CacheFormulaImpl < CacheImpl
    include Wiris

        def initialize(conf)
            super(conf)
            @cacheFolder = getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER)
        end

    end
end
