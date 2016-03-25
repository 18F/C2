RSpec.configure do |config|
  retry_error_types = [ 
    Capybara::Poltergeist::DeadClient
  ]
  retry_count = ENV.fetch("RSPEC_RETRIES", 3).to_i
  config.around(:each) do |spec|
    retry_count.times do |i|
      spec.run
      example = spec.example

      if example.exception.nil? || !retry_error_types.include?(example.exception.class)
        break # Stop the retry loop and proceed to the next spec
      end 
 
      # If we got to this point, then a retry-able exception has been thrown by the spec
      e_line = example.location_rerun_argument
      puts "Error (#{example.exception.class} - #{example.exception}) occurred while running rspec example (#{e_line}"
 
      if i < retry_count
        puts "Re-running rspec example (#{e_line}. Retry count #{i+1} of #{retry_count}"

        # do not clear exception if we run out of tries
        if i < (retry_count - 1)
          example.instance_variable_set('@exception', nil)
        end
      end
    end   
  end
end
