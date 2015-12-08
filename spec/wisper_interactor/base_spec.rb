require 'spec_helper'

RSpec.describe WisperInteractor::Base do

  it "includes the the Interactor module" do
    expect(described_class.ancestors).to include Interactor
  end

  it "includes the Wisper::Publisher module" do
    expect(described_class.ancestors).to include Wisper::Publisher
  end

end
