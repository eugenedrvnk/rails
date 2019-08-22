class CommentsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_channel_#{params[:id]}"
    p '*' * 100
    p params[:id]
    p '*' * 100
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
