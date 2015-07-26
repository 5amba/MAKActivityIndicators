Pod::Spec.new do |s|

  s.name        = 'MAKActivityIndicators'
  s.version     = '0.1'
  s.platform = :ios
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.summary		= 'A compilation of activity indicator views'
  s.author		= 'Martin Klöpfel'
  s.homepage	= 'https://github.com/5amba'
  s.platform    = :ios, '6.0'
  s.source      = { :git => 'https://github.com/5amba/MAKActivityIndicators.git',
  					:branch => 'master',
                    :tag => '0.1'
                    }
  s.source_files = 'MAKActivityIndicators/**/*.{h,m}'
  s.weak_frameworks = ['UIKit', 'Foundation']
  s.requires_arc = true

end
