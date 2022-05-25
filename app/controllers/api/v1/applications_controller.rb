class Api::V1::ApplicationsController < ApplicationController
  before_action :set_application, only: %i[update destroy]

  # GET /api/v1/applications
  # FixME: Too naiive, should add pagination for later
  def index
    @applications = Application.all.select(:name, :token).to_json(except: :id)
    json_response(@applications)
  end

  # POST /api/v1/applications
  def create
    @application = Application.create!({ name: params[:name], chats_count: 0 })
    json_response(@application.token, :created)
  end

  # GET /api/v1/applications/:token
  def show
    application = Application.where(token: params[:token]).select(:name, :token).to_json(except: :id)
    json_response(application)
  end

  # PUT /api/v1/applications/:token
  def update
    @application.update({ name: params[:name] })
    head :no_content
  end

  # DELETE /api/v1/applications/:token
  def destroy
    @application.destroy
    head :no_content
  end

  private

  def application_params
    # whitelist params
    params.permit(:token, :name)
  end

  def set_application
    @application = Application.find_by!(token: params[:token])
  end
end
