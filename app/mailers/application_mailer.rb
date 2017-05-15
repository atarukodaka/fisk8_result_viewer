class ApplicationMailer < ActionMailer::Base
  #default from: 'from@example.com'
  default from: ENV['GMAIL_ADDRESS']
  layout 'mailer'
end
