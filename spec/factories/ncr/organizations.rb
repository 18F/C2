FactoryGirl.define do
  factory :ncr_organization, class: Ncr::Organization do
    code "123ABC"
    name "Test org"

    factory :ool_organization do
      code Ncr::Organization::OOL_CODES.first
    end

    factory :whsc_organization do
      code Ncr::Organization::WHSC_CODE
      name "(192X,192M) WHITE HOUSE DISTRICT"
    end
  end
end
