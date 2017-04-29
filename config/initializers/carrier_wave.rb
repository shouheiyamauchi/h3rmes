if Rails.env.production?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      # Configuration for Amazon S3
      :provider              => 'AWS',
      :aws_access_key_id     => 'AKIAJGNDYO4PQUKPRNYQ',
      :aws_secret_access_key => '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',
      :region                => 'ap-southeast-2'
    }
    config.fog_directory     =  'h3rmes'
  end
end
