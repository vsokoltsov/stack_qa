class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :define_question, only: [:edit, :show, :update, :destroy]
  before_action :widget_data, only: :index

  def index
    @questions = Question.all
  end

  def new
    @question = Question.new
  end

  def edit
  end

  def show
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
      render json: {success: true}, status: :ok
    else
      render json: @question.errors.to_json, status: :forbidden
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

  def widget_data
    @widget = Question.order("created_at DESC").first(5)
  end

  def question_params
    params.require(:question).permit(:title, :text, :user_id, :category_id)
  end
end