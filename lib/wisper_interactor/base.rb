require 'interactor'
require 'wisper'

module WisperInteractor
  class Base
    include Interactor
    include Wisper::Publisher

  end
end
