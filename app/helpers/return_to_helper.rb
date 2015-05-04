module ReturnToHelper
  def make_return_to(name, path)
    sig = OpenSSL::HMAC.digest(
      OpenSSL::Digest::SHA256.new,
      Rails.application.secrets.secret_key_base,
      name + "$" + path
    )
    {name: name, path: path, sig: Base64.urlsafe_encode64(sig)}
  end
end
