require "../../../spec_helper"
require "../../../support/helpers/cli_helper"
require "../../../support/fixtures/cli_fixtures"

include CLIHelper
include CLIFixtures

module Amber::CLI
  describe "amber generate" do
    ENV["AMBER_ENV"] = "test"
    camel_case = "PostComment"
    snake_case = "post_comment"
    incorrect_case = "Post_comment"
    display = "Post Comment"
    class_definition_prefix = "class #{camel_case}"
    spec_definition_prefix = "describe #{camel_case}"

    scaffold_app(TESTING_APP)

    describe "controller" do
      options = %w(add:post list:get remove:delete)
      MainCommand.run %w(generate controller -y animal) | options
      route_file = File.read("./config/routes.cr")

      it "generates controller with correct verbs and actions" do
        generated_controller = "./src/controllers/animal_controller.cr"
        File.read(generated_controller).should eq expected_animal_controller
      end

      options.each do |route|
        action, method = route.split(":")
        it "creates a valid #{method} route for #{action}" do
          route_file.includes?(build_route("animal", action, method)).should be_true
        end
      end

      it "follows naming conventions for all files and class names" do
        [camel_case, snake_case].each do |arg|
          MainCommand.run ["generate", "controller", "-y", arg]
          filename = snake_case
          src_filepath = "./src/controllers/#{filename}_controller.cr"
          spec_filepath = "./spec/controllers/#{filename}_controller_spec.cr"

          File.exists?(src_filepath).should be_true
          File.exists?(spec_filepath).should be_true
          File.read(src_filepath).should contain class_definition_prefix
          File.read(spec_filepath).should contain spec_definition_prefix
          File.delete(src_filepath)
          File.delete(spec_filepath)
        end
      end
    end

    describe "model" do
      MainCommand.run %w(
        generate model -y Post title:string body:text published:bool likes:int user:references
      )

      it "creates Post migration file" do
        generated_migration = Dir["./db/migrations/*_post.sql"].first
        File.read(generated_migration).should eq expected_post_model_migration
      end

      it "generates Post model spec file" do
        generated_spec = "./spec/models/post_spec.cr"
        File.read(generated_spec).should eq expected_post_model_spec
      end

      it "generates Post model" do
        generated_model = "src/models/post.cr"
        File.read(generated_model).should eq expected_post_model
      end
    end

    describe "scaffold" do
      it "follows naming conventions for all files and class names" do
        [camel_case, snake_case].each do |arg|
          MainCommand.run ["generate", "scaffold", "-y", arg, "name:string"]

          File.exists?("./spec/models/#{snake_case}_spec.cr").should be_true
          File.exists?("./src/models/#{snake_case}.cr").should be_true
          File.exists?("./spec/controllers/#{snake_case}_controller_spec.cr").should be_true
          File.exists?("./src/controllers/#{snake_case}_controller.cr").should be_true
          File.exists?("./src/views/#{snake_case}/_form.slang").should be_true
          File.exists?("./src/views/#{snake_case}/edit.slang").should be_true
          File.exists?("./src/views/#{snake_case}/index.slang").should be_true
          File.exists?("./src/views/#{snake_case}/new.slang").should be_true
          File.exists?("./src/views/#{snake_case}/show.slang").should be_true
          File.read("./spec/models/#{snake_case}_spec.cr").should contain spec_definition_prefix
          File.read("./src/models/#{snake_case}.cr").should contain class_definition_prefix
          File.read("./spec/controllers/#{snake_case}_controller_spec.cr").should contain spec_definition_prefix
          File.read("./src/controllers/#{snake_case}_controller.cr").should contain class_definition_prefix
          File.read("./src/views/#{snake_case}/_form.slang").should contain snake_case
          File.read("./src/views/#{snake_case}/edit.slang").should contain display
          File.read("./src/views/#{snake_case}/index.slang").should contain display
          File.read("./src/views/#{snake_case}/new.slang").should contain display
          File.read("./src/views/#{snake_case}/show.slang").should contain snake_case
          File.read("./config/routes.cr").should contain "#{camel_case}Controller"
          File.read("./config/routes.cr").should_not contain "#{incorrect_case}Controller"
        end
      end
    end

    describe "migration" do
      it "follows naming conventions for all files" do
        [camel_case, snake_case].each do |arg|
          MainCommand.run ["generate", "migration", "-y", arg]

          migration_filename = Dir.entries("./db/migrations").sort.last
          migration_filename.should contain snake_case
          File.delete("./db/migrations/#{migration_filename}")
        end
      end
    end

    describe "mailer" do
      it "follows naming conventions for all files and class names" do
        [camel_case, snake_case].each do |arg|
          MainCommand.run ["generate", "mailer", "-y", arg]
          filename = snake_case
          src_filepath = "./src/mailers/#{filename}_mailer.cr"

          File.exists?(src_filepath).should be_true
          File.read(src_filepath).should contain class_definition_prefix
          File.delete(src_filepath)
        end
      end
    end

    describe "socket" do
      struct_definition_prefix = "struct #{camel_case}"

      it "follows naming conventions for all files and class names" do
        [camel_case, snake_case].each do |arg|
          MainCommand.run ["generate", "socket", "-y", arg]
          filename = snake_case
          src_filepath = "./src/sockets/#{filename}_socket.cr"

          File.exists?(src_filepath).should be_true
          File.read(src_filepath).should contain struct_definition_prefix
          File.delete(src_filepath)
        end
      end
    end

    describe "channel" do
      it "follows naming conventions for all files and class names" do
        [camel_case, snake_case].each do |arg|
          MainCommand.run ["generate", "channel", "-y", arg]
          filename = snake_case
          src_filepath = "./src/channels/#{filename}_channel.cr"

          File.exists?(src_filepath).should be_true
          File.read(src_filepath).should contain class_definition_prefix
          File.delete(src_filepath)
        end
      end
    end
  end
end
