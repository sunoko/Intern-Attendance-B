# if Rails.env.production?
#   CarrierWave.configure do |config|
#     config.fog_credentials = {
#       # Amazon S3用の設定
#       :provider              => 'AWS',
#       :region                => ENV['ap-northeast-1'],     # 例: 'ap-northeast-1'
#       :aws_access_key_id     => ENV['AKIAIFYVKZK7IDQAZY7A'],
#       :aws_secret_access_key => ENV['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']
#     }
#     config.fog_directory     =  ENV['kaneko']
#   end
# end