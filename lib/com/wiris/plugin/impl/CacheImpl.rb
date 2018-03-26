module WirisPlugin
include  Wiris
    require('com/wiris/plugin/api/ConfigurationKeys.rb')
    require('com/wiris/util/sys/Store.rb')
    require('com/wiris/util/sys/Cache.rb')
    require('com/wiris/util/sys/Cache.rb')
    class CacheImpl
    extend CacheInterface

    include Wiris

        attr_accessor :conf
        attr_accessor :cacheFolder
    @@backwards_compat;
        def self.backwards_compat
            @@backwards_compat
        end
        def self.backwards_compat=(backwards_compat)
            @@backwards_compat = backwards_compat
        end
        def initialize(conf)
            super()
            @conf = conf
            @cacheFolder = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
        end
        def set(key, value)
            extension = Std::substr(key,key::indexOf("."),key::length() - key::indexOf("."))
            digest = Std::substr(key,0,key::indexOf(extension))
            parent = getFolderStore(@cacheFolder,digest)
            parent::mkdirs()
            store = getFileStoreWithParent(parent,digest,extension)
            store::writeBinary(value)
        end
        def get(key)
            extension = Std::substr(key,key::indexOf("."),key::length() - key::indexOf("."))
            digest = Std::substr(key,0,key::indexOf(extension))
            store = getFileStore(@cacheFolder,digest,extension)
            if @@backwards_compat
                if !store::exists()
                    oldstore = Store::newStore(((@cacheFolder + "/") + digest) + extension)
                    if !oldstore::exists()
                        return nil
                    end
                    parent = store::getParent()
                    parent::mkdirs()
                    oldstore::moveTo(store)
                end
            else 
                if !store::exists()
                    return nil
                end
            end
            return store::readBinary()
        end
        def deleteAll()
            formulaFolder = getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER)
            cacheFolder = getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER)
            includes = Array.new()
            includes::push("svg")
            includes::push("png")
            includes::push("csv")
            includes::push("txt")
            if !(PropertiesTools::getProperty(@conf,ConfigurationKeys::SAVE_MODE,"xml") == "image")
                includes::push("ini")
            end
            Store::deleteDirectory(formulaFolder,includes)
            Store::deleteDirectory(cacheFolder,includes)
        end
        def delete(key)
        end
        def getAndCheckFolder(key)
            folder = PropertiesTools::getProperty(@conf,key)
            if (folder == nil) || (folder::trim()::length() == 0)
                raise Exception,"Missing configuration value: " + key
            end
            return folder
        end
        def getFileStoreWithParent(parent, digest, extension)
            return Store::newStoreWithParent(parent,Std::substr(digest,4).to_s + extension)
        end
        def getFileStore(dir, digest, extension)
            return getFileStoreWithParent(getFolderStore(dir,digest),digest,extension)
        end
        def getFolderStore(dir, digest)
            return Store::newStore((((dir + "/") + Std::substr(digest,0,2).to_s) + "/") + Std::substr(digest,2,2).to_s)
        end
        def updateFoldersStructure()
            updateFolderStructure(getAndCheckFolder(ConfigurationKeys::CACHE_FOLDER))
            updateFolderStructure(getAndCheckFolder(ConfigurationKeys::FORMULA_FOLDER))
        end
        def updateFolderStructure(dir)
            folder = Store::newStore(dir)
            files = folder::list()
            if files != nil
                for i in 0..files::length - 1
                    digest = isFormulaFileName(files[i])
                    if digest != nil
                        newFolder = getFolderStore(dir,digest)
                        newFolder::mkdirs()
                        newFile = getFileStoreWithParent(newFolder,digest,Std::substr(files[i],files[i]::indexOf(".") + 1))
                        file = Store::newStoreWithParent(folder,files[i])
                        file::moveTo(newFile)
                    end
                    i+=1
                end
            end
        end
        def isFormulaFileName(name)
            i = name::indexOf(".")
            if i == -1
                return nil
            end
            digest = Std::substr(name,0,i)
            if digest::length() != 32
                return nil
            end
            return digest
        end

    @@backwards_compat = true
    end
end
