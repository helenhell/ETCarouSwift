Pod::Spec.new do |spec|

  
  spec.name         = "ETCarouSwift"
  spec.version      = "1.1.0"
  spec.summary      = "A user-friendly and developer-friendly carousel framework written in Swift."

  spec.description  = <<-DESC
   "ETCarouSwift receives a bunch of images and creates a smooth infinite ride inside the given frame. Dragging is also avaliable along with other handy settings. Simple, light and flawless"
                   DESC

  spec.homepage     = "https://github.com/helenhell/ETCarouSwift"
  spec.license      = "MIT"
  spec.author             = { "Elena Slovushch" => "elena.slovushch@gmail.com" }
  spec.platform     = :ios
  spec.source       = { :git => "https://github.com/helenhell/ETCarouSwift", :tag => "#{spec.version}" }

  spec.source_files  = "ETCarouSwift", "ETCarouSwift/*.{h,swift}"
  spec.swift_version = "5.0"
  

end
