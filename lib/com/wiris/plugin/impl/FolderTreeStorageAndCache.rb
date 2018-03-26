module WirisPlugin
include  Wiris
    require('com/wiris/plugin/storage/StorageAndCache.rb')
    require('com/wiris/plugin/impl/CacheImpl.rb')
    require('com/wiris/plugin/storage/StorageAndCache.rb')
    class FolderTreeStorageAndCache
    extend StorageAndCacheInterface

    include Wiris

        attr_accessor :config
    @@backwards_compat;
        def self.backwards_compat
            @@backwards_compat
        end
        def self.backwards_compat=(backwards_compat)
            @@backwards_compat = backwards_compat
        end
        attr_accessor :cache
        attr_accessor :cacheFormula
        def initialize()
            super()
        end
        def init(obj, config, cache, cacheFormula)
            @config = config
            @cache = cache
            @cacheFormula = cacheFormula
        end
        def codeDigest(content)
            digest = Md5Tools::encodeString(content)
            begin
            cacheFormula::set(digest + ".ini",Bytes::ofData(Utf8::toBytes(content)))
            end
            return digest
        end
        def decodeDigest(digest)
            data = cacheFormula::get(digest + ".ini")
            if data != nil
                return Utf8::fromBytes(data::getData())
            else 
                return nil
            end
        end
        def retreiveData(digest, service)
            data = cache::get((digest + ".") + getExtension(service))
            if data != nil
                return data::getData()
            else 
                return nil
            end
        end
        def storeData(digest, service, stream)
            begin
            cache::set((digest + ".") + getExtension(service),Bytes::ofData(stream))
            end
        end
        def getExtension(service)
            if (service == "png")
                return "png"
            end
            if (service == "svg")
                return "svg"
            end
            return service + ".txt"
        end
        def deleteCache()
            cache = CacheImpl.new(@config)
            begin
            cache::deleteAll()
            end
        end

    @@backwards_compat = true
    end
end
