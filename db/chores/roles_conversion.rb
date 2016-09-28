class RolesConversion
  def ncr_budget_approvers
    ba61_tier1_budget_team_approver
    ba61_tier1_budget_approver
    ba61_tier2_budget_approver
    ba80_budget_approver
    ool_ba80_budget_approver
  end

  def gsa18f_approvers
    gsa18f_approver
    gsa18f_purchaser
    gsa18f_talent_approver
  end

  def gateway_roles
    gateway_admin
  end

  private

  def ba61_tier1_budget_team_approver
    with_email_role_slug!(
      "gsa.approver+ba61_team@gmail.com",
      "BA61_tier1_budget_team_approver",
      "ncr"
    )
  end

  def ba61_tier1_budget_approver
    with_email_role_slug!(
      "gsa.approver+ba61_tier1@gmail.com",
      "BA61_tier1_budget_approver",
      "ncr"
    )
  end

  def ba61_tier2_budget_approver
    with_email_role_slug!(
      "gsa.approver+ba61_tier2@gmail.com",
      "BA61_tier2_budget_approver",
      "ncr"
    )
  end

  def ba80_budget_approver
    with_email_role_slug!(
      "gsa.approver+ba80@gmail.com",
      "BA80_budget_approver",
      "ncr"
    )
  end

  def ool_ba80_budget_approver
    with_email_role_slug!(
      "gsa.approver+ool_ba80@gmail.com",
      "OOL_BA80_budget_approver",
      "ncr"
    )
  end

  def gsa18f_approver
    with_email_role_slug!(
      "gsa.approver+18f_approver@gmail.com",
      "gsa18f_approver",
      "gsa18f"
    )
  end

  def gsa18f_purchaser
    with_email_role_slug!(
      "gsa.approver+18f_purchaser@gmail.com",
      "gsa18f_purchaser",
      "gsa18f"
    )
  end

  def gsa18f_talent_approver
    with_email_role_slug!(
      "gsa.approver+18f_talent_approver@gmail.com",
      "gsa18f_talent_approver",
      "gsa18f"
    )
  end

  def gateway_admin
    with_email_role_slug!(
      "gsa.approver+gateway_admin@gmail.com",
      "gateway_admin",
      nil
    )
  end

  # find_or_create a User with particular email, role and slug
  # NOTE the triple is considered unique, so if a user with the role+slug
  # is found with another email address, no change is made and nil is returned.
  def with_email_role_slug!(email, role_name, slug)
    # unique triple -- check if any other user with role+slug already exists
    return if exists_with_role_slug?(role_name, slug)

    user = User.for_email(email)
    # if no change necessary, return early (idempotent)
    if user.client_slug == slug && user.roles.exists?(name: role_name)
      return user
    end

    user.client_slug = slug
    user.add_role(role_name)
    user.save!
    user
  end

  def exists_with_role_slug?(role_name, slug)
    role = Role.find_by_name(role_name)
    role && role.users.exists?(client_slug: slug)
  end
end
