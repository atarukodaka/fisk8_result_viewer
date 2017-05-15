class FeedbackMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.feedback_mailer.sendmail_confirm.subject
  #
  def send_mail(body)
    @body = body

    mail to: ENV['GMAIL_ADDRESS'], subject: 'fisk8viewer pull request'
  end
end
