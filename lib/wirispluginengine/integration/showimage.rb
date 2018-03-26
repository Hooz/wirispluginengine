class ShowImage
	def dispatch(request, response, provider, pb)
		render = pb.newRender()
		formula = provider.getParameter('formula', nil);
		mml = provider.getParameter('mml', nil);
		if (pb.getConfiguration().getProperty('wirispluginperformance', 'false') == 'true')

            useragent = provider.getParameter("useragent", "");
            if (useragent == "IE")
                pb.getConfiguration().setProperty("wirisimageformat", "png")
            else
                pb.getConfiguration().setProperty("wirisimageformat", "svg")
            end

			response.content_type = 'application/json'
			if (formula.nil?)
				render.showImage(formula, mml, provider);
				formula = render.computeDigest(mml, provider.getParameters());
			end
			r = render.showImageJson(formula, 'en');
			response.body = r;
		else
			r = render.showImage(formula, mml, provider);
			response.content_type = pb.getImageFormatController().getContentType();
			return r
		end
	end
end
