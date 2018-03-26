module WirisPlugin
include  Wiris
    require('com/wiris/util/xml/EntityResolver.rb')
    require('com/wiris/util/xml/WXmlUtils.rb')
    require('com/wiris/util/xml/EntityResolver.rb')
    class MathMLEntityResolver
    extend EntityResolverInterface

    include Wiris

        def initialize()
            super()
        end
        def resolveEntity(name)
            return WXmlUtils::resolveMathMLEntity(name)
        end

    end
end
