module Mailtrap
  module API
    private

    def prepare_request(request, request_class)
      normalised = request.is_a?(request_class) ? request : build_entity(request, request_class)
      normalised.to_h
    end

    def build_entity(options, response_class)
      response_class.new(options.slice(*response_class.members))
    end
  end
end
