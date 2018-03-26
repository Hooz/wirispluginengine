require_dependency "wirispluginengine/integration/configurationjs"
require_dependency "wirispluginengine/integration/createimage"
require_dependency "wirispluginengine/integration/showimage"
require_dependency "wirispluginengine/integration/service"
require_dependency "wirispluginengine/integration/getmathml"
require_dependency "wirispluginengine/integration/test"
require_dependency "wirispluginengine/integration/cleancache"
require_dependency "wirispluginengine/integration/resource"
require_dependency "wirispluginengine/integration/configurationjson"
require_dependency "wirispluginengine/integration/testfilter"
require_dependency "com/wiris/plugin/api/PluginBuilder"

module Wirispluginengine
  class ApplicationController < ActionController::Base
    include Wiris
    include WirisPlugin
    def integration
      #Loading resources for WirisPlugin (gem/resources dir).
      spec = Gem::Specification.find_by_name("wirispluginengine")
      gem_root = spec.gem_dir
      Storage.resourcesDir = gem_root.to_s + '/resources'

      wirishash = Hash.new()
      params.each do |key, value|
        wirishash[key] = value
      end
      propertiesparams = PropertiesTools.toProperties(wirishash)
      rcu = RubyConfigurationUpdater.new()
      rcu.request = request
      pb = PluginBuilderImpl.getInstance()
      pb.addConfigurationUpdater(rcu)
      provider = GenericParamsProviderImpl.new(propertiesparams)
      pb.setStorageAndCacheCacheObject(CacheImpl.new(pb.getConfiguration().getFullConfiguration()));
      pb.setStorageAndCacheCacheFormulaObject(CacheFormulaImpl.new(pb.getConfiguration().getFullConfiguration()));

      pb.addCorsHeaders(HttpResponse.new(self), request.headers['Origin'])

      case self.params[:script].inspect.gsub('"', '')
      when 'configurationjs'
        configurationjs = Configurationjs.new
        render :js =>  configurationjs.dispatch(request, response, pb)
      when 'createimage'
        createimage = CreateImage.new
        render :plain => createimage.dispatch(request, response, provider, pb)
      when 'showimage'
        showimage = ShowImage.new
        image = showimage.dispatch(request, response, provider, pb)
        if (pb.getConfiguration().getProperty('wirispluginperformance', 'false') == 'true')
          expires_in 60.minutes
          render :json => image
        else
          send_data image.pack("C*"), :type => response.content_type, :disposition => 'inline'
        end
      when 'service'
        service = Service.new()
        render :plain => service.dispatch(request, response, provider, pb)
      when 'getmathml'
        getmathml = GetMathMLDispatcher.new()
        render :text => getmathml.dispatch(request, response, provider, pb)
      when 'test'
        #test variable changed to wiristest
        #in order to avoid conflict with rails production consoles
        wiristest = WirisTest.new()
        render :html => wiristest.dispatch(request, pb).html_safe
      when 'cleancache'
        wiriscleancache = CleanCache.new()
        render :text => wiriscleancache.dispatch(request, response, provider, pb)
      when 'resource'
        wirisresource = Resource.new()
        render :text => wirisresource.dispatch(response, provider, pb)
      when 'configurationjson'
        wirisconfiguration = ConfigurationJson.new()
        render :json => wirisconfiguration.dispatch(request, response, provider, pb)
      when 'testfilter'
        filteredText = TestFilter.new()
        render :plain => filteredText.dispatch(request, response, provider, pb)

      else
        render plain:"Method no exists"
      end
      Storage.resourcesDir = nil
    end
  end
end
