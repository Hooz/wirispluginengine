class TestFilter
	def dispatch(request, response, provider, pb)

        s = "<html><body><b>Formula: </b><math><mfrac><mi>x</mi><mn>1000</mn></mfrac></math></body></html>"
        p  = Hash.new()
		output = pb.newTextService.filter(s,p)
        response.content_type = 'text/html'
        return output;
	end
end
