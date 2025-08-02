require "json"
package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react_native_adhan"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]
  s.source       = { :git => package["repository"]["url"], :tag => "v#{s.version}" }
  s.platform     = :ios, "13.0"
  s.swift_version = "5.0"

  # Source files for both Swift and Objective-C++
  s.source_files = "ios/**/*.{h,m,mm,swift}"

  # Module name and dependencies
  s.module_name = "react_native_adhan"

  # React Native core dependencies
  s.dependency "React-Core"
  s.dependency "ReactCommon/turbomodule/core"
  s.dependency "React-Codegen"

  # Build settings for Swift and C++ interop
  s.pod_target_xcconfig = {
    "DEFINES_MODULE"               => "YES",
    "CLANG_ENABLE_MODULES"         => "YES",
    "SWIFT_VERSION"                => "5.0",
    "CLANG_CXX_LANGUAGE_STANDARD"  => "c++17"
  }

  # Auto-link React Native modules
  install_modules_dependencies(s)
end