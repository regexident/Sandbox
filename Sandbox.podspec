Pod::Spec.new do |s|

  s.name         = "Sandbox"
  s.version      = "1.0.0"
  s.summary      = "A simple to use yet versatile API for dealing with sandboxed file access."

  s.description  = <<-DESC
                   Sandbox aims to hides the awkward logistics required to let your app access files outside its own scope behind a simple and sane closure-based synchronous API, while keeping you in full control over your app's logical flow.
                   DESC

  s.homepage     = "https://github.com/regexident/Sandbox"
  s.license      = { :type => 'BSD-3', :file => 'LICENSE' }
  s.author       = { "Vincent Esche" => "regexident@gmail.com" }
  s.source       = { :git => "https://github.com/regexident/Sandbox.git", :tag => '1.0.0' }
  s.source_files  = "Sandbox/Classes/*.{swift,h,m}"
  # s.public_header_files = "Sandbox/*.h"
  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  
end
