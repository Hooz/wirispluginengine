module WirisPlugin
	class RubyConfigurationUpdater
		include Wiris
		def request
		@request
		end
		def request=(request)
		@request=request
		end

		def init(obj)
		end

		def updateConfiguration(configuration)
			v =PropertiesTools::getProperty(configuration, ConfigurationKeys::CACHE_FOLDER, nil)
			if v.nil?
				configuration[ConfigurationKeys::CACHE_FOLDER] = File.dirname(__FILE__) +  "/../../cache"
			end
			v =PropertiesTools::getProperty(configuration, ConfigurationKeys::FORMULA_FOLDER, nil)
			if v.nil?
				configuration[ConfigurationKeys::FORMULA_FOLDER] = File.dirname(__FILE__) +  "/../../formulas"
			end
			v =PropertiesTools::getProperty(configuration, ConfigurationKeys::SHOWIMAGE_PATH, nil)
			if v.nil?
				configuration[ConfigurationKeys::SHOWIMAGE_PATH] = "wirispluginengine/integration/showimage?formula="
			end
			v =PropertiesTools::getProperty(configuration, ConfigurationKeys::CLEAN_CACHE_PATH, nil)
			if v.nil?
				configuration[ConfigurationKeys::CLEAN_CACHE_PATH] = "cleancache"
			end
			v =PropertiesTools::getProperty(configuration, ConfigurationKeys::RESOURCE_PATH, nil)
			if v.nil?
				configuration[ConfigurationKeys::RESOURCE_PATH] = "resource"
			end
			v =PropertiesTools::getProperty(configuration, ConfigurationKeys::CONFIGURATION_PATH, nil)
			if v.nil?
				if File.file?(Rails.root.join('vendor', 'wiris', 'configuration.ini'))
					configuration[ConfigurationKeys::CONFIGURATION_PATH] = Rails.root.join('vendor', 'wiris').to_s
				else
					configuration[ConfigurationKeys::CONFIGURATION_PATH] = File.dirname(__FILE__) + "/../../"
				end
			end
			v = PropertiesTools::getProperty(configuration, ConfigurationKeys::REFERER, nil)
			if v.nil?
				configuration[ConfigurationKeys::REFERER] = request.original_url
			end
		end
	end
end
