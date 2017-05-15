class FeedbackController < ApplicationController
  def index
  end

  def submit
    ## commit to database
    
    ## send mail
    competition_url = params[:competition_url]
    competition_name = params[:competition_name]

    if competition_url.blank?
      #redirect_to controller: :feedback, action: :index, params: {url_missing: true}
      @warning = "URL is missing"
      render action: :index
    else
      body = "#{competition_url}, #{competition_name}"
      @mail = FeedbackMailer.send_mail(body).deliver
      # TODO error handling
      @message = "Thank you for your feedback"
      render action: :index
    end
  end
end
