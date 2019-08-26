class PostsController < ApplicationController
  before_action :check_post_change_access, only: [:edit, :update, :destroy]
  before_action :user_email_confirmed, only: [:create, :edit, :update, :destroy]

  def create
    @user = User.find(params[:user_id])
    @post = @user.posts.new(post_params.except(:images))
    if @post.save
      flash[:success] = 'Post created'
    else
      flash[:error] = 'Title & Body can\'t be blank'
    end
    # redirect_to root_path

    #
    # respond_to do |format|
    #     if @post.save
    #         format.js { render :action => "create" }
    #     else
    #         format.js { render :action => "create_error" }
    #     end
    # end
    #
    urls = []
    unless post_params[:images].nil?
      post_params[:images].each do |post_image|
        @post.images.create(data: post_image)
      end
    end
    ActionCable.server.broadcast "user_channel_#{@post.user.id}",
    type: 'post_create',
    div: (render partial: 'posts/post_full', locals: {post: @post})
  end

  def show
  end

  def destroy
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:id])
    ActionCable.server.broadcast "user_channel_#{@post.user_id}",
    type: 'post_delete',
    post_id: @post.id
    @post.destroy

    # redirect_to @user
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    JSON.parse(params[:images_to_delete]).each do |id|
      image = Image.find(id)
      image.data.remove!
      image.destroy
    end
    new_images = post_params[:images]
    @post = Post.find(params[:id])
    if new_images.nil?
      @post.update(post_params.except(:images))
      flash[:success] = 'Post updated'
      redirect_to @post.user
    else
      count = @post.images.count
      @post.update(post_params.except(:images))
      post_params[:images].each do |post_image|
        next if count == 5
        @post.images.create(data: post_image)
        count += 1
      end
      flash[:success] = 'Post updated'
      redirect_to @post.user
    end
    BroadcastUserChannelJob.perform_later @post
  end

  def post_params
    params.require(:post).permit!
  end

  def check_post_change_access
    if current_user.nil?
      redirect_to login_path
    elsif Post.find(params[:id]).user != current_user
      redirect_to current_user
    end
  end

end

