require "../../../../src/amber/controller/helpers/render"

module Fixtures::CLI::Generate
  module ErrorController
    include Amber::Controller::Helpers::Render
    extend self

    def expected_error_controller
      <<-CONT
      require "amber/controller/helpers/render"

      class ErrorController < Amber::Controller::Error
        include Amber::Controller::Helpers::Render
        LAYOUT = "application.slang"

        def forbidden
          render("forbidden.slang")
        end

        def not_found
          render("not_found.slang")
        end

        def internal_server_error
          render("internal_server_error.slang")
        end
      end

      CONT
    end
  end
end
