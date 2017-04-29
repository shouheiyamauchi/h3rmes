if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :aws_access_key_id     => ENV['AKIAJGNDYO4PQUKPRNYQ'],
      :aws_secret_access_key => ENV['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'],
      :region                => ENV['ap-southeast-2']
    }
    config.fog_directory     =  ENV['h3rmes']
  end
end
