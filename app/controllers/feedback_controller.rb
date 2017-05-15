class FeedbackController < ApplicationController
  def index
  end

  def pull_request
    ## commit to database
    
    ## send mail
    competition_url = params[:competition_url]
    competition_name = params[:competition_name]

    if competition_url.blank?
      redirect_to controller: :feedback, action: :index, params: {url_missing: true}
      #render action: :index, params: {warning: 'URL is missing'} and return
    else
      body = "#{competition_url}, #{competition_name}"
      @mail = FeedbackMailer.send_mail(body).deliver
      # TODO error handling
    end
  end
end
