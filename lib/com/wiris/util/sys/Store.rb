module WirisPlugin
include  Wiris
    require('com/wiris/common/WInteger.rb')
    class Store
    include Wiris

        attr_accessor :file
        def initialize()
            super()
        end
        def self.newStore(folder)
            s = Store.new()
            s::file = folder
            return s
        end
        def list()
            return FileSystem::readDirectory(@file)
        end
        def mkdirs()
            parent = getParent()
            if !parent::exists() && !((parent::getFile() == @file))
                parent::mkdirs()
            end
            if !exists()
                FileSystem::createDirectory(@file)
            end
        end
        def write(str)
            File::saveContent(@file,str)
        end
        def writeBinary(bs)
            File::saveBytes(@file,bs)
        end
        def readBinary()
            return File::getBytes(@file)
        end
        def append(str)
            output = File::append(@file,true)
            output::writeString(str)
            output::flush()
            output::close()
        end
        def read()
            return File::getContent(@file)
        end
        def self.newStoreWithParent(store, str)
            return Store.newStore((store::getFile() + "/") + str)
        end
        def getFile()
            return @file
        end
        def exists()
            return FileSystem::exists(@file)
        end
        def self.getCurrentPath()
            return FileSystem::fullPath(".")
        end
        def getParent()
            parent = FileSystem::fullPath(@file)
            if parent == nil
                parent = @file
            end
            i = WInteger::max(parent::lastIndexOf("/"),parent::lastIndexOf("\\"))
            if i < 0
                return Store.newStore(".")
            end
            parent = Std::substr(parent,0,i)
            return Store.newStore(parent)
        end
        def copyTo(dest)
            b = readBinary()
            dest::writeBinary(b)
        end
        def moveTo(dest)
            FileSystem::rename(@file,dest::getFile())
        end
        def delete()
            if FileSystem::isDirectory(@file)
                FileSystem::deleteDirectory(@file)
            else 
                FileSystem::deleteFile(@file)
            end
        end
        def deleteFolderContents()
            if exists() && FileSystem::isDirectory(getFile())
                files = list()
                for i in 0..files::length - 1
                    if !((files[i] == ".") || (files[i] == ".."))
                        f = Store::newStoreWithParent(self,files[i])
                        if FileSystem::isDirectory(f::getFile())
                            f::deleteFolderContents()
                            FileSystem::deleteDirectory(f::getFile())
                        else 
                            FileSystem::deleteFile(f::getFile())
                        end
                    end
                    i+=1
                end
            end
        end
        def self.deleteDirectory(folder, included)
            if (folder == nil) || !FileSystem::exists(folder)
                return 
            end
            path = FileSystem::fullPath(folder)
            files = FileSystem::readDirectory(folder)
            i = 0
            for i in 0..files::length - 1
                file = files[i]
                file = (path + '/'.to_s) + file
                if FileSystem::isDirectory(file)
                    Store.deleteDirectory(file,included)
                else 
                    includedIterator = included::iterator()
                    if included != nil
                        while includedIterator::hasNext()
                            if StringTools::endsWith(file,includedIterator::next())
                                FileSystem::deleteFile(file)
                            end
                        end
                    else 
                        FileSystem::deleteFile(file)
                    end
                end
                i+=1
            end
            files = FileSystem::readDirectory(folder)
            if files::length == 0
                FileSystem::deleteDirectory(folder)
            end
        end

    end
end
