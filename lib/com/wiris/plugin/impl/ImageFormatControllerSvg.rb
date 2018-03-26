module WirisPlugin
include  Wiris
    require('com/wiris/plugin/api/ImageFormatController.rb')
    require('com/wiris/plugin/api/ImageFormatController.rb')
    class ImageFormatControllerSvg
    extend ImageFormatControllerInterface

    include Wiris

        def initialize()
            super()
        end
        def getContentType()
            return "image/svg+xml"
        end
        def getMetrics(bytes, ref_output)
            svg = bytes::toString()
            svgRoot = Std::substr(svg,0,svg::indexOf(">"))
            firstIndex = svgRoot::indexOf("height=") + 8
            endIndex = svgRoot::indexOf("\"",firstIndex)
            height = Std::substr(svgRoot,firstIndex,endIndex - firstIndex)
            firstIndex = svgRoot::indexOf("width=") + 7
            endIndex = svgRoot::indexOf("\"",firstIndex)
            width = Std::substr(svgRoot,firstIndex,endIndex - firstIndex)
            firstIndex = svgRoot::indexOf("wrs:baseline=") + 14
            endIndex = svgRoot::indexOf("\"",firstIndex)
            baseline = Std::substr(svgRoot,firstIndex,endIndex - firstIndex)
            output = ref_output
            if output != nil
                PropertiesTools::setProperty(output,"width","" + width)
                PropertiesTools::setProperty(output,"height","" + height)
                PropertiesTools::setProperty(output,"baseline","" + baseline)
                r = ""
            else 
                r = (((("&cw=" + width) + "&ch=") + height) + "&cb=") + baseline
            end
            return r
        end
        def scalateMetrics(dpi, metrics)
        end

    end
end
