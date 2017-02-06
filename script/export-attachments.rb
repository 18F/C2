# This exports all attachments found in a CSV export of proposals
# (as created by the Report UI) from their S3 bucket, and stores
# them locally in a set of folders numbered by proposal ID.

require "optparse"
require "pry"
require "csv"
require 'net/http'
require 'tempfile'
require 'uri'
require 'restclient'
require 'aws-sdk'
require 'fileutils'


EXPORT_DIR = "export/"
CURRENT_PROPOSAL_FOLDER = "export/current_proposal/"
FILEPATH_REGEX = /^https:\/\/[\w.-]+\/([^\?]+)\?/
Dir.mkdir(EXPORT_DIR) if !Dir.exist?(EXPORT_DIR)
Dir.mkdir(CURRENT_PROPOSAL_FOLDER) if !Dir.exist?(CURRENT_PROPOSAL_FOLDER)

# Read CSV filename from command line

csv_filename = ""
aws_secret_access_key = ""
aws_access_key_id = ""
bucket_name = ""
aws_region = ""

OptionParser.new do |opts|
  opts.on("-c", "--csv RECORDS.csv",
          "Export attachments specified in RECORDS.csv") do |filename|
    csv_filename = filename
  end
  opts.on("-s", "--aws-secret AWS_SECRET_ACCESS_KEY") do |id|
    aws_secret_access_key = id
  end
  opts.on("-i", "--aws-id AWS_ACCESS_KEY_ID") do |id|
    aws_access_key_id = id
  end
  opts.on("-b", "--bucket BUCKET_NAME") do |id|
    bucket_name = id
  end
  opts.on("-r", "--aws-region AWS_REGION") do |id|
    aws_region = id
  end
end.parse!

Aws.config.update(
  region: aws_region,
  credentials: Aws::Credentials.new(aws_access_key_id, aws_secret_access_key)
)

if csv_filename =~ /\S/
  puts "Opening #{csv_filename}"
else
  abort "Need to specify a CSV export file (use -c)"
end

# Open CSV
# Build hash of proposal ID => array of attachment URLs
proposals = {}

CSV.foreach(csv_filename, headers: true ) do |row|
  proposals[row[0].to_i] = row["Attachments"].gsub(/"|\[|\]/,"").split(',')
end

# TODO: Create export & current proposal folders, or
# check for their existence

# Look in export/ folder for completed proposal folders
# Find the highest folder number

last_completed = Dir.entries(EXPORT_DIR)[2..-1].map(&:to_i).sort[-1] || 0

# empty current-proposal/
def empty_current_proposal_dir
  Dir.foreach(CURRENT_PROPOSAL_FOLDER) do |filename|
    if filename !~ /^\./
      puts filename
      fn = File.join(CURRENT_PROPOSAL_FOLDER, filename); 
      File.delete(fn)
    end
  end
end



def save_file directory, object_key, filename, bucket_name
  s3 = Aws::S3::Client.new(region:"us-gov-west-1")
  begin
    File.open(File.join(directory,filename), 'wb' ) do |file|
      s3.get_object({ bucket: bucket_name, key: object_key }, target: file)
    end
  rescue Aws::S3::Errors::NoSuchKey
    puts "File Doesn't exist"
  end
end

# For each proposal record
proposals.keys.sort.each do |id|
  next if id < last_completed || proposals[id].length < 1
  # for each attachment URL
  puts "Proposal ID = #{id}"
  puts "# of Attachments = #{proposals[id].length}"
  empty_current_proposal_dir
    proposals[id].each do |url|
      # strip URL down to file path
      match = url.match(FILEPATH_REGEX)
      if match
        filepath = match[1]
        filename = filepath.match(/\/([^\/]+)\/?$/)[1]
        object_key = match[1]
        puts "object_key = #{object_key}"
        puts "filename = #{filename}"
        puts "full path = #{match[0]}"
        save_file(CURRENT_PROPOSAL_FOLDER, object_key, filename, bucket_name)
      end
    end
    # move files to export/[proposal id]/
    FileUtils.cp_r "#{CURRENT_PROPOSAL_FOLDER}.", "#{EXPORT_DIR}#{id}"
end

puts "Done!"
