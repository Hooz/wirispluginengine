require 'erb'
require 'uri'
module Wiris
    class StringTools
        def self.replace(text, target, replacement)
            text = text.gsub(target, replacement)
            return text
        end

        def self.startsWith(s, start)
            return s.start_with?(start)
        end

        def self.endsWith(s, ends)
            return s.end_with?(ends)
        end

        def self.urlEncode(s)
            return ERB::Util::url_encode(s);
        end

        def self.urlDecode(s)
            return URI.unescape(s)
        end

        def self.trim(s)
            return s.strip
        end

        def self.hex(n, digits)
            hex = n.to_s(16).upcase
            while hex.length() < digits
                hex = "0" + hex
            end
            return hex.upcase
        end

        def self.compare(s1,s2)
            return s1<=>s2
        end
    end
end