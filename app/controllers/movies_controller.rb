class MoviesController < ApplicationController
  before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy, :join, :quit]
  before_action :find_movie_and_check_permission, only: [:edit, :update, :destroy]
  def index
    @movies = Movie.all
  end

  def new
    @movie = Movie.new
  end

  def show
    @movie = Movie.find(params[:id])
    @reviews = @movie.reviews.recent.paginate(:page => params[:page], :per_page => 5)
   end

   def edit
     @movie = Movie.find(params[:id])
   end

   def create
    @movie = Movie.new(movie_params)
    @movie.user = current_user

    if @movie.save
      current_user.join!(@movie)
      redirect_to movies_path
    else
      render :new
    end
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update(movie_params)
      redirect_to movies_path, notice: "Update Success!"
    else
      render :edit
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path, alert: "Movie deleted!"
  end

  def join
    @movie = Movie.find(params[:id])

    if !current_user.is_member_of?(@movie)
      current_user.join!(@movie)
      flash[:notice] = "Favorited Success!"
    else
      flash[:warning] = "You have favorited the movie!"
  end
   redirect_to movie_path(@movie)
 end


  def quit
    @movie = Movie.find(params[:id])

    if current_user.is_member_of?(@movie)
      current_user.quit!(@movie)
      flash[:alert] = "Not favorited the movie"
    else
      flash[:warning] = "你还没有收藏本影片，怎么退出！"
    end
    redirect_to movie_path(@movie)
  end

  private

  def find_movie_and_check_permission
    @movie = Movie.find(params[:id])

    if current_user != @movie.user
      redirect_to root_path, alert: "You have no permission!"
  end
end

  def movie_params
    params.require(:movie).permit(:title, :description)
  end
end
