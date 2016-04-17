#
#  Be sure to run `pod spec lint YAHModel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "YAHModel"
  s.version      = "0.0.2"
  s.summary      = "JSON and Model networking framework."

  s.description  = <<-DESC
                   Data Networking, change JSON Data to Model
                   DESC

  s.homepage     = "https://github.com/yahua/YAHModel.git"

  s.license      = "MIT"

  s.author             = { "yahua" => "yahua523@163.com" }
  
  s.platform     = :ios, "7.0"
  s.requires_arc = true

  s.source       = { :git => "https://github.com/yahua/YAHModel.git", :tag => "0.0.2" }



  s.source_files  = "YAHModel/*.{h,m}"
  s.public_header_files = 'YAHModel/*.{h}'
  
  s.frameworks = "Foundation", "UIKit"

end
