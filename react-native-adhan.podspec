require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-adhan"
  s.version      = package["version"] || "1.0.0"
  s.summary      = package["description"] || "React Native Adhan TurboModule"
  s.homepage     = package["homepage"] || "https://github.com/maxto024/react-native-adhan"
  s.license      = package["license"] || "MIT"
  s.authors      = package["author"] || { "Author" => "author@example.com" }

  s.platforms    = { ios: "13.0" }
  s.source       = { git: "https://github.com/maxto024/react-native-adhan.git", tag: s.version }

  s.source_files = [
    "ios/Adhan.h",
    "ios/Adhan.mm"
  ]

  # React Native core dependencies
  s.dependency "React-Core"
end