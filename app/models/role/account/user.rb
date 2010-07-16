module Role::Account::User
  include Role::Base
  
  allow :create_health_checks, :edit_health_checks, :delete_health_checks, :run_health_checks,
        :create_sites, :edit_sites, :delete_sites
end
