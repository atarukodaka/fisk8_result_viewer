require 'rails_helper'

RSpec.describe Datatable::ColumnDefs do
  describe Datatable do
    context 'giving column_def as symbol' do
      subject(:column_def){
        Datatable.new.records([]).columns([:foo]).column_defs[:foo]
      }
      its(:name) { is_expected.to eq("foo") }
      its(:source) { is_expected.to eq("foo") }
    end
    context 'giving column_def as hash' do
      subject(:column_def){
        Datatable.new.columns([{name: "foo", source: "foos.foo"}]).column_defs[:foo]
      }
      its(:name) { is_expected.to eq("foo") }
      its(:source) { is_expected.to eq("foos.foo") }
    end
  end
  describe ScoresDatatable do
    context "giving column_def as symbol" do
      subject(:column_def){  ScoresDatatable.new.columns([:foo]).column_defs[:foo] }
      its(:name) { is_expected.to eq("foo") }
    end
    context "giving column_def as hash" do
      subject(:column_def){ ScoresDatatable.new.columns([{name: "foo"}]).column_defs[:foo] }
      its(:name) { is_expected.to eq("foo") }
      its(:source) { is_expected.to eq("scores.foo") }
    end
  end
end
