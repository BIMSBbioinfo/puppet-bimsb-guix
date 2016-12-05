require 'spec_helper'
describe 'guix' do

  context 'with defaults for all parameters' do
    it { should contain_class('guix') }
  end
end
