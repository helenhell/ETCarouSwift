Pod::Spec.new do |spec|

  
  spec.name         = "ETCarouSwift"
  spec.version      = "2.0.0"
  spec.summary      = "A user-friendly and developer-friendly carousel framework written in SwiftUI."

  spec.description  = <<-DESC
   "ETCarouSwift receives a bunch of images and creates a smooth infinite ride inside the given frame. Dragging is also avaliable along with other handy settings. Simple, light and flawless. Now built with SwiftUI for modern iOS development."
                   DESC

  spec.homepage     = "https://github.com/helenhell/ETCarouSwift"
  spec.license      = 'MIT'
  spec.author             = { "Elena Slovushch" => "elena.slovushch@gmail.com" }
  spec.platform     = :ios, '13.0'
  spec.source       = { :git => "https://github.com/helenhell/ETCarouSwift.git", :tag => "#{spec.version}" }

  spec.source_files  = "ETCarouSwift", "ETCarouSwift/*.{h,swift}"
  spec.swift_version = "5.0"
  

end
