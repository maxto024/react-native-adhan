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
  s.swift_version = "5.0"  # Also set below in xcconfig

  # ✅ Include both Objective-C++ and Swift
  s.source_files = "ios/**/*.{h,m,mm,swift}"

  # ✅ Explicit module definition to trigger bridging header generation
  s.module_name = "Adhan"

  # ✅ Key Swift bridging fixes (no use_frameworks! needed)
  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES",
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++17",
    "SWIFT_VERSION" => "5.0"
  }

  # ✅ React Native dependencies
  s.dependency "React-Codegen"
  s.dependency "ReactCommon/turbomodule/core"
  s.dependency "React-Core"

  s.pod_target_xcconfig = {
    "DEFINES_MODULE"               => "YES",
    "CLANG_ENABLE_MODULES"        => "YES",
    "SWIFT_VERSION"               => "5.0",
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
  }

  s.pod_target_xcconfig = {
    "DEFINES_MODULE"               => "YES",
    "CLANG_ENABLE_MODULES"        => "YES",
    "SWIFT_VERSION"               => "5.0",
    "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
  }

  install_modules_dependencies(s)
end