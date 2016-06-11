# Configuration for the C2 Application. The `01_` prefix ensures that this initializer is
# executed first.

SYSTEM_ROLES = [
  ROLE_BETA_USER    = "beta_user".freeze,
  ROLE_BETA_ACTIVE  = "beta_active".freeze,
  ROLE_ADMIN        = "admin".freeze,
  ROLE_CLIENT_ADMIN = "client_admin".freeze,
  ROLE_OBSERVER     = "observer".freeze
].freeze
