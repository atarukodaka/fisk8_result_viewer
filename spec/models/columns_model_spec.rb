require 'rails_helper'

RSpec.describe AjaxDatatables::Columns do
  describe AjaxDatatables do
    context 'giving column as symbol' do
      subject(:column) {
        AjaxDatatables::Datatable.new.columns([:foo]).columns[:foo]
      }
      its(:name) { is_expected.to eq('foo') }
      its(:source) { is_expected.to eq('.foo') }
    end
    context 'giving column as hash' do
      subject(:column) {
        AjaxDatatables::Datatable.new.columns([{ name: 'foo', source: 'foos.foo' }]).columns[:foo]
      }
      its(:name) { is_expected.to eq('foo') }
      its(:source) { is_expected.to eq('foos.foo') }
    end
    context 'specify model' do
      subject(:column) {
        AjaxDatatables::Datatable.new.columns([:foo]).records(Skater.all).columns[:foo]
      }
      its(:name) { is_expected.to eq('foo') }
      its(:source) { is_expected.to eq('skaters.foo') }
    end
  end
  describe ScoresDatatable do
    context 'giving column as symbol' do
      subject(:column) { ScoresDatatable.new.columns([:foo]).columns[:foo] }
      its(:name) { is_expected.to eq('foo') }
    end
    context 'giving column as hash' do
      subject(:column) { ScoresDatatable.new.columns([{ name: 'foo' }]).columns[:foo] }
      its(:name) { is_expected.to eq('foo') }
      its(:source) { is_expected.to eq('scores.foo') }
    end
  end
end
