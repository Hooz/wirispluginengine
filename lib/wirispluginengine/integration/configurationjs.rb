# Rails don't load at the begining in production environment the libraries. We need to import it.
require_relative '../../com/wiris/plugin/impl/PluginBuilderImpl.rb'
class Configurationjs
    def dispatch (request, response, pb)
        conf = pb.getConfiguration()
        response.body = conf.getJavaScriptConfigurationJson()

    end
end