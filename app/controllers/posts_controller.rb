class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
  @posts = Post.includes(:user).all.order(created_at: :desc)
  @categories = Post.where.not(category: [nil, '']).distinct.pluck(:category).sort
  
  if params[:query].present?
    search_query = "%#{params[:query]}%"
    @posts = @posts.where("title LIKE ? OR category LIKE ? OR content LIKE ?",
                          search_query, search_query, search_query)
  end
end
  def search
    posts = Post.all.includes(:user)
    posts = posts.where("content LIKE ? OR title LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
    posts = posts.where(category: params[:category]) if params[:category].present?
    posts = posts.where(user_id: Array(params[:user_ids]).map(&:to_i)) if params[:user_ids].present?
    posts = params[:sort] == 'oldest' ? posts.order(created_at: :asc) : posts.order(created_at: :desc)
    render json: posts.limit(50).map { |p|
      {
        id:          p.id,
        title:       p.title,
        body:        p.content.to_s.truncate(100),
        post_type:   p.try(:category) || 'text',
        author_name: p.user&.username || p.user&.email&.split('@')&.first || 'Χρήστης',
        created_at:  p.created_at.strftime('%d/%m/%Y %H:%M')
      }
    }
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = current_user.posts.build(post_params)
    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Η ανάρτηση δημιουργήθηκε με επιτυχία!" }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @post.destroy!
    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def set_post
      @post = Post.find(params.expect(:id))
    end

    def post_params
      params.expect(post: [ :title, :content, :user_id, :category ])
    end

end