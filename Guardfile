# Exclude features from the command to run all specs. Guard will still run features if a
# feature spec is changed.
guard :rspec, cmd: "bin/rspec --exclude-pattern 'spec/features/**/*_spec.rb'" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch("spec/spec_helper.rb")  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch("config/routes.rb")                           { "spec/routing" }
  watch("app/controllers/application_controller.rb")  { "spec/controllers" }
  watch("spec/rails_helper.rb")                       { "spec" }

  # Capybara features specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml|slim)$})     { |m| "spec/features/#{m[1]}_spec.rb" }
end

# We're not using this at the moment. Also, its output obscures the preceding
# RSpec results when all tests are run.

# guard :shell do
#   watch(%r{^app/assets/javascripts/(.+)\.js(\.coffee)?$}) { |m| `bin/rake konacha:run SPEC=#{m[1]}_spec` }
#   watch(%r{^spec/javascripts/(.+)\.js(\.coffee)?$}) { |m| `bin/rake konacha:run SPEC=#{m[1]}` }
# end
