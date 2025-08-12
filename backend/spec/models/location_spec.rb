RSpec.describe Location, type: :model do
  let(:country) { create(:country) }
  subject { create(:location, country: country, name: "Las Condes") }

  it do
    expect(subject).to validate_uniqueness_of(:normalized_name)
      .scoped_to(:country_id)
      .case_insensitive
  end
end
