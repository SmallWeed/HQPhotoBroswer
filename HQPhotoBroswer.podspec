
Pod::Spec.new do |s|
s.name         = 'HQPhotoBroswer'
s.version      = '0.0.1'
s.summary      = 'An easy way to use scorll advertisement'
s.homepage     = 'https://github.com/SmallWeed/HQPhotoBroswer'
s.license      = 'MIT'
s.authors      = {'Smallweed' => '491041442@qq.com'}
s.platform     = :ios, '6.0'
s.source       = {:git => 'https://github.com/SmallWeed/HQPhotoBroswer.git', :tag => s.version}
s.source_files = 'HQPhotoBroswer/**/*.{h,m}'
s.resource     = 'HQPhotoBroswer/**/*.{png,xib,storyboard}'
s.requires_arc = true
s.dependency 'SDWebImage'
end