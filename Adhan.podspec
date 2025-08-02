require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "Adhan"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  s.source       = { :git => package["repository"]["url"], :tag => "v#{s.version}" }
  s.platforms    = { :ios => "13.0" }
  s.swift_version = "5.0"

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  install_modules_dependencies(s)
end
