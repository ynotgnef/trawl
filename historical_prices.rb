# separate historical and daily trawl - this is not necessary, automatic based on naming scheme
# individual files - <TICKER>_<begin>-<end>
# single period files - SINGLE_PERIOD_<period>
# generate the individual files once then generate single period each day
# keep a running list of which individuals are not up do date and generate individuals for each
# if not going with database approach, run background script to convert individual to single period
# only need single period for heat map
# but database is preferable in long run for future modeling
# data base needs primary key ticker and index based on date

# parallize as much as possible
# pass in path to ticker_list.txt

require_relative './helpers/helpers.rb'
require_relative './helpers/trawl_helpers.rb'
require_relative './helpers/aws_helpers.rb'

secrets = Helpers.load_yaml('config/secrets.yml')
tickers_url = "#{secrets['jenkins_url']}#{secrets['ticker_list']}"
username = secrets['jenkins_username']
password = secrets['jenkins_password']

tickers = TrawlHelpers.retrieve_tickers_list(tickers_url, username, password)

aws_region = secrets['AWS_REGION']
aws_credentials = {
  aws_key_id: secrets['AWS_ACCESS_KEY_ID'],
  aws_access_key: secrets['AWS_SECRET_ACCESS_KEY']
}

s3_bucket = AWSHelpers.init_s3_resource(
  aws_region,
  aws_credentials
).bucket('trawl-storage')

# tickers.split.each do |ticker|
tickers[0..5].each do |ticker|
puts ticker
end
