# Allows a return-to path and name to be present in the GET params. The values
# are HMACed to verify that they came from our app (preventing injection
# attacks), though there is no protection against replay attacks (it's unclear
# what the attack would be)
module ReturnToHelper
  def make_return_to(name, path)
    sig = OpenSSL::HMAC.digest(
      OpenSSL::Digest::SHA256.new,
      Rails.application.secrets.secret_key_base,
      name + "$" + path
    )
    {name: name, path: path, sig: Base64.urlsafe_encode64(sig)}
  end

  protected
  def return_to
    if params[:return_to]
      return_to = params.require(:return_to)
      proper_sig = self.make_return_to(return_to.require(:name),
                                       return_to.require(:path))[:sig]
      if return_to.require(:sig) == proper_sig
        return_to.permit([:path, :name])
      end
    end
  end
end
