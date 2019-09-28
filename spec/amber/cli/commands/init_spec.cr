require "../../../spec_helper"
require "../../../support/helpers/cli_helper"

include CLIHelper

module Amber::CLI
  describe "amber new #{TESTING_APP}" do
    ENV["AMBER_ENV"] = "test"

    scaffold_app(TESTING_APP)
    camel_case = "PostComment"
    snake_case = "post_comment"
    class_definition_prefix = "class #{camel_case}"
    spec_definition_prefix = "describe #{camel_case}"

    it "generates amber directory structure" do
      dirs(TESTING_APP).sort.should eq dirs(APP_TEMPLATE_PATH).sort
    end

    it "follows naming conventions for all files and class names" do
      [camel_case, snake_case].each do |arg|
        MainCommand.run ["generate", "model", "-y", arg]
        filename = snake_case
        granite_table_name = "table #{snake_case}s"
        src_filepath = "./src/models/#{filename}.cr"
        spec_filepath = "./spec/models/#{filename}_spec.cr"
        File.exists?(src_filepath).should be_true
        File.exists?(spec_filepath).should be_true
        File.read(src_filepath).should contain class_definition_prefix
        File.read(src_filepath).should contain granite_table_name
        File.read(spec_filepath).should contain spec_definition_prefix
        File.delete(src_filepath)
        File.delete(spec_filepath)
      end
    end

    context "-r recipe (damianham/default)" do
      scaffold_app(TESTING_APP, "-r", "damianham/default")

      it "generates amber directory structure" do
        dirs(TESTING_APP).sort.should eq dirs(APP_TEMPLATE_PATH).sort
      end
    end
  end

  context "Database settings" do
    %w(pg mysql sqlite).each do |db|
      MainCommand.run ["new", TESTING_APP, "-y", "--no-deps", "-d", db]
      prepare_yaml(TESTING_APP)

      describe "#{db}" do
        %w(development test).each do |env|
          db_key = db == "sqlite" ? "sqlite3" : db
          db_url = environment_yml(env)["database_url"].as_s

          context "is #{env.upcase}" do
            it "sets #{db} shards dependencies" do
              shard_yml["dependencies"][db_key].should_not be_nil
            end

            it "has correct database connection string" do
              db_url.should eq expected_db_url(db_key, env)
            end
          end
        end
      end

      describe "template" do
        it "sets ECR templates" do
          MainCommand.run ["new", TESTING_APP, "-y", "--no-deps", "-t", "ecr"]
          amber_yml["language"].should eq "ecr"
        end

        it "it defaults to Slang templates" do
          MainCommand.run ["new", TESTING_APP, "-y", "--no-deps", "-t", "slang"]
          amber_yml["language"].should eq "slang"
        end
      end
    end
  end
end
