Pod::Spec.new do |spec|

  spec.name         = "ETCarouSwift"
  spec.version      = "1.0.0"
  spec.summary      = "A user-friendly and developer-friendly version of classic carousel"

  spec.description  = <<-DESC
  "ETCarouSwift receives a bunch of images and creates a smooth infinite ride inside the given frame. Dragging is also avaliable along with other handy settings. Simple, light and flawless"
                   DESC

  spec.homepage     = "https://github.com/helenhell/ETCarouSwift"
  spec.license      = "MIT"
  spec.author       = { "Helenhell" => "apperative@gmail.com" }
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/helenhell/ETCarouSwift.git", :tag => "1.0.0" }
  spec.source_files  = "ETCarouSwift/**/*.[m,h,swift]"
  
  
end
