if EnvCredentials.s3_bucket_name && EnvCredentials.s3_access_key_id && EnvCredentials.s3_secret_access_key
  Paperclip::Attachment.default_options.merge!(
    bucket: EnvCredentials.s3_bucket_name,
    s3_credentials: {
      access_key_id: EnvCredentials.s3_access_key_id,
      secret_access_key: EnvCredentials.s3_secret_access_key,
    },
    s3_region: EnvCredentials.s3_region,
    s3_permissions: :private,
    storage: :s3,
  )
end
