require "paperclip"

module S3File
  extend ActiveSupport::Concern

  included do
    if S3Credentials.s3_bucket_name && S3Credentials.s3_access_key_id && S3Credentials.s3_secret_access_key
      has_attached_file :file,
                        storage: :s3,
                        s3_credentials: {
                          bucket: S3Credentials.s3_bucket_name,
                          access_key_id: S3Credentials.s3_access_key_id,
                          secret_access_key: S3Credentials.s3_secret_access_key
                        },
                        s3_permissions: {
                          original: "private"
                        },
                        s3_region: S3Credentials.s3_region
    else
      has_attached_file :file
    end
  end
end
