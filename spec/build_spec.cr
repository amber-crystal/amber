require "./spec_helper"
require "./support/helpers/cli_helper"

include CLIHelper

module Amber::CLI
  begin
    describe "building a generated app" do
      ENV["AMBER_ENV"] = "test"

      cleanup
      scaffold_app(TESTING_APP)

      options = ["user:reference", "name:string", "body:text", "age:integer", "published:bool"]
      temp_options = options - ["user:reference", "age:integer"]
      MainCommand.run ["generate", "auth", "User"] | (options - ["user:reference"])
      MainCommand.run ["generate", "error"]
      MainCommand.run ["generate", "scaffold", "Animal"] | temp_options
      MainCommand.run ["generate", "scaffold", "Post"] | options
      MainCommand.run ["generate", "scaffold", "PostComment"] | (options + ["post:reference"])
      MainCommand.run ["generate", "model", "Bat"] | options
      MainCommand.run ["generate", "migration", "Crocodile"] | options
      MainCommand.run ["generate", "mailer", "Dinosaur"] | options
      MainCommand.run ["generate", "socket", "Eagle"] | ["soar", "nest"]
      MainCommand.run ["generate", "channel", "Falcon"]

      prepare_yaml(Dir.current)
      Amber::CLI.env = "test"
      Amber::CLI.settings.logger = Amber::Environment::Logger.new(nil)


      puts "RUNNING: waiting postgres database"
      wait_pg_isready

      puts "RUNNING: db drop create"
      MainCommand.run ["db", "drop", "create"]

      puts "RUNNING: shards update"
      `shards update`

      puts "RUNNING: shards build"
      build_result = `shards build #{TEST_APP_NAME}`

      it "generates a binary" do
        puts build_result unless File.exists?("bin/#{TEST_APP_NAME}")
        File.exists?("bin/#{TEST_APP_NAME}").should be_true
      end

      context "crystal spec" do
        puts "RUNNING: waiting postgres database"
        wait_pg_isready
        puts "RUNNING: crystal spec"
        spec_result = `crystal spec`

        it "can be executed" do
          puts spec_result unless spec_result.includes? "Finished in"
          spec_result.should contain "Finished in"
        end

        it "has no errors" do
          puts spec_result if spec_result.includes? "Error in line"
          spec_result.should_not contain "Error in line"
        end

        it "has no failures" do
          puts spec_result if spec_result.includes? "Failures"
          spec_result.should_not contain "Failures"
        end
      end
    end
  ensure
    cleanup
  end
end
# Trigger build
# Trigger build
# Trigger build
# Trigger build
# Trigger build
# Trigger build
# Trigger build
# Trigger build
# Trigger build
