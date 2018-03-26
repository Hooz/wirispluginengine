module WirisPlugin
include  Wiris
    require('com/wiris/util/sys/Cache.rb')
    require('com/wiris/util/sys/Cache.rb')
    class StoreCache
    extend CacheInterface

    include Wiris

        attr_accessor :cachedir
        def initialize(cachedir)
            super()
            @cachedir = Storage::newStorage(cachedir)
            if !cachedir::exists()
                cachedir::mkdirs()
            end
            if !(cachedir::exists())
                raise Exception,("Variable folder \"" + cachedir::toString().to_s) + "\" does not exist and can\'t be automatically created. Please create it with write permissions."
            end
        end
        def set(key, value)
            s = getItemStore(key)
            begin
            s::writeBinary(value::getData())
            end
        end
        def get(key)
            s = getItemStore(key)
            if s::exists()
                begin
                return Bytes::ofData(s::readBinary())
                end
            else 
                return nil
            end
        end
        def deleteAll()
            deleteStorageDir(@cachedir)
        end
        def deleteStorageDir(s)
            if s::exists() && s::isDirectory()
                files = s::list()
                for i in 0..files::length - 1
                    if !((files[i] == ".") || (files[i] == ".."))
                        f = Storage::newStorageWithParent(s,files[i])
                        if f::isDirectory()
                            deleteStorageDir(f)
                        end
                        f::delete()
                    end
                    i+=1
                end
            end
        end
        def delete(key)
            getItemStore(key)::delete()
        end
        def getItemStore(key)
            return Storage::newStorageWithParent(@cachedir,key)
        end

    end
end
