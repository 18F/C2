# Contains functions which make client selection/branching easier
module ClientHelper
  def client_partial(client_name, path, args={})
    client_name ||= "ncr"   # @TODO: set this to default once we've migrated users
    to_check = client_name + "/" + path
    default_check = "default/" + path
    if lookup_context.template_exists?(to_check, [], true)
      args[:partial] = to_check
      render(args)
    elsif lookup_context.template_exists?(default_check, [], true)
      args[:partial] = default_check
      render(args)
    else
      ""
    end
  end
end
