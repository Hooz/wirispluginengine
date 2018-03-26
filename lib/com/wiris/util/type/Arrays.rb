module WirisPlugin
include  Wiris
    class Arrays
    include Wiris

        def initialize()
            super()
        end
        def self.newIntArray(length, initValue)
            data = []
            length-=1
            while length >= 0
                data[length] = initValue
                length-=1
            end
            return data
        end
        def self.indexOfElement(array, element)
            i = 0
            n = array::length()
            while i < n
                if (array::_(i) != nil) && ((array::_(i) == element))
                    return i
                end
                i+=1
            end
            return -1
        end
        def self.fromIterator(iterator)
            array = Array.new()
            while iterator::hasNext()
                array::push(iterator::next())
            end
            return array
        end
        def self.fromCSV(s)
            words = Std::split(s,",")
            i = 0
            while i < words::length()
                w = words::_(i)::trim()
                if w::length() > 0
                    words::_(i,w)
                    i+=1
                else 
                    words::splice(i,1)
                end
            end
            return words
        end
        def self.contains(array, element)
            return Arrays.indexOfElement(array,element) >= 0
        end
        def self.indexOfElementArray(array, element)
            for i in 0..array::length - 1
                if (array[i] != nil) && (array[i] == element)
                    return i
                end
                i+=1
            end
            return -1
        end
        def self.indexOfElementInt(array, element)
            for i in 0..array::length - 1
                if array[i] == element
                    return i
                end
                i+=1
            end
            return -1
        end
        def self.containsArray(array, element)
            return Arrays.indexOfElementArray(array,element) >= 0
        end
        def self.containsInt(array, element)
            return Arrays.indexOfElementInt(array,element) >= 0
        end
        def self.clear(a)
            i = a::length() - 1
            while i >= 0
                a::remove(a::_(i))
                i-=1
            end
        end
        def self.sort(elements, comparator)
            Arrays::quicksort(elements,0,elements::length() - 1,comparator)
        end
        def self.insertSorted(a, e)
            Arrays.insertSortedImpl(a,e,false)
        end
        def self.insertSortedSet(a, e)
            Arrays.insertSortedImpl(a,e,true)
        end
        def self.insertSortedImpl(a, e, set)
            imin = 0
            imax = a::length()
            while imin < imax
                imid = ((imax + imin)/2)
                cmp = Reflect::compare(a::_(imid),e)
                if cmp == 0
                    if set
                        return 
                    else 
                        imin = imid
                        imax = imid
                    end
                else 
                    if cmp < 0
                        imin = imid + 1
                    else 
                        imax = imid
                    end
                end
            end
            a::insert(imin,e)
        end
        def self.binarySearch(array, key)
            imin = 0
            imax = array::length()
            while imin < imax
                imid = ((imin + imax)/2)
                cmp = Reflect::compare(array::_(imid),key)
                if cmp == 0
                    return imid
                else 
                    if cmp < 0
                        imin = imid + 1
                    else 
                        imax = imid
                    end
                end
            end
            return -1
        end
        def self.copyArray(a)
            b = Array.new()
            i = a::iterator()
            while i::hasNext()
                b::push(i::next())
            end
            return b
        end
        def self.addAll(baseArray, additionArray)
            i = additionArray::iterator()
            while i::hasNext()
                baseArray::push(i::next())
            end
        end
        def self.quicksort(elements, lower, higher, comparator)
            if lower < higher
                p = Arrays::partition(elements,lower,higher,comparator)
                Arrays::quicksort(elements,lower,p - 1,comparator)
                Arrays::quicksort(elements,p + 1,higher,comparator)
            end
        end
        def self.partition(elements, lower, higher, comparator)
            pivot = elements::_(higher)
            i = lower - 1
            j = lower
            while j < higher
                if comparator::compare(pivot,elements::_(j)) > 0
                    i+=1
                    if i != j
                        swapper = elements::_(i)
                        elements::_(i,elements::_(j))
                        elements::_(j,swapper)
                    end
                end
                j+=1
            end
            if comparator::compare(elements::_(i + 1),elements::_(higher)) > 0
                finalSwap = elements::_(i + 1)
                elements::_(i + 1,elements::_(higher))
                elements::_(higher,finalSwap)
            end
            return i + 1
        end
        def self.firstElement(elements)
            return elements::_(0)
        end
        def self.lastElement(elements)
            return elements::_(elements::length() - 1)
        end

    end
end
