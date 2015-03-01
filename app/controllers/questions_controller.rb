class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :define_question, only: [:edit, :show, :update, :destroy, :sign_in_question]
  include Rating
  include UserStatistic

  def index
    @questions = Question.top
  end

  def new
    @question = Question.new
  end

  def edit
  end

  def show
    @question.update(views: @question.views += 1)
  end

  def create
    question = Question.new(question_params)
    if question.save
      PrivatePub.publish_to "/questions", question: question.to_json
      render nothing: true
    else
      render json: question.errors.to_json, status: :forbidden
    end
  end

  def update
    if @question.update(question_params)
      Question.delay.signed_users(@question)
      render json: {success: true}, status: :ok
    else
      render json: @question.errors.to_json, status: :forbidden
    end
  end

  def sign_in_question
    if QuestionUser.find_by(user_id: current_user.id, question_id: @question.id)
      render json: {message: "Вы уже подписаны на данное обновление"} and return
    end

    if QuestionUser.create(user_id: current_user.id, question_id: @question.id)
      render json: {message: "Вы подписались на данный вопрос"}, status: :ok
    else
      render json: {error: "К сожалению,подписка не может быть оформлена"}, status: :unprocessible_entity
    end
  end


  def destroy
    @question.destroy
    head :ok
  end

  private

  def define_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :text, :user_id, :category_id)
  end

end