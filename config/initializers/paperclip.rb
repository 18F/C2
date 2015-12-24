if ENV["S3_BUCKET_NAME"] && ENV["S3_ACCESS_KEY_ID"] && ENV["S3_SECRET_ACCESS_KEY"]
  Paperclip::Attachment.default_options.merge!(
    bucket: ENV["S3_BUCKET_NAME"],
    s3_credentials: {
      access_key_id: ENV["S3_ACCESS_KEY_ID"],
      secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
    },
    s3_permissions: :private,
    storage: :s3,
  )
end
