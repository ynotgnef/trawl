# aws helpers
module AWSHelpers
  require 'aws-sdk'

  module_function

  def init_s3_resource(region, credentials)
    Aws::S3::Resource.new(
      region: region,
      credentials: credentials
    )
  end
  module_function :init_s3_resource

  def save_to_s3(s3_bucket, origin, destination)
    File.open(origin, 'rb') do |file|
      s3_bucket.put_object(
        {
          key: destination,
          body: file
        }
      )
    end
  end
  module_function :save_to_s3

  def check_if_exists(s3_bucket, track_path)
    s3_bucket.object(track_path).exists?
  end
  module_function :check_if_exists
end