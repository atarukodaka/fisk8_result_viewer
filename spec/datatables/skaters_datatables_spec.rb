require 'rails_helper'

feature SkatersDatatable do
  let!(:competition) { create(:competition, :world) }
  let(:datatable) { SkatersDatatable.new }

  describe 'records' do
    subject { datatable }
    its(:records) { is_expected.not_to be nil }
  end
  describe 'columns/name' do
    subject { datatable.columns[:name] }
    it { is_expected.not_to be nil }
    its(:source) { is_expected.to eq('skaters.name') }
    its(:table_name) { is_expected.to eq('skaters') }
    its(:table_field) { is_expected.to eq('name') }
    its(:table_model) { is_expected.to eq(Skater) }
  end
end
