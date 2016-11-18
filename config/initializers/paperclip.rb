if S3Credentials.s3_bucket_name && S3Credentials.s3_access_key_id && S3Credentials.s3_secret_access_key
  Paperclip::Attachment.default_options.merge!(
    bucket: S3Credentials.s3_bucket_name,
    s3_credentials: {
      access_key_id: S3Credentials.s3_access_key_id,
      secret_access_key: S3Credentials.s3_secret_access_key,
    },
    s3_region: S3Credentials.s3_region,
    s3_permissions: :private,
    storage: :s3,
  )
end
