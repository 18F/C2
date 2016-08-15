# frozen_string_literal: true
# Configuration for the C2 Application.
#
# The `01_` prefix ensures that this initializer is executed first.

SYSTEM_ROLES = [
  ROLE_BETA_USER      = "beta_user",
  ROLE_BETA_ACTIVE    = "beta_active",
  ROLE_ADMIN          = "admin",
  ROLE_CLIENT_ADMIN   = "client_admin",
  ROLE_GATEWAY_ADMIN  = "gateway_admin",
  ROLE_OBSERVER       = "observer"
].freeze
