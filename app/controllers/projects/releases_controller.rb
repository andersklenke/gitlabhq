# frozen_string_literal: true

class Projects::ReleasesController < Projects::ApplicationController
  # Authorize
  before_action :require_non_empty_project, except: [:index]
  before_action :release, only: %i[edit show update downloads]
  before_action :authorize_read_release!
  before_action do
    push_frontend_feature_flag(:release_issue_summary, project)
    push_frontend_feature_flag(:release_evidence_collection, project, default_enabled: true)
    push_frontend_feature_flag(:release_show_page, project)
  end
  before_action :authorize_update_release!, only: %i[edit update]
  before_action :authorize_read_release_evidence!, only: [:evidence]

  def index
    respond_to do |format|
      format.html do
        require_non_empty_project
      end
      format.json { render json: releases }
    end
  end

  def evidence
    respond_to do |format|
      format.json do
        render json: release.evidence_summary
      end
    end
  end

  def show
    return render_404 unless Feature.enabled?(:release_show_page, project)

    respond_to do |format|
      format.html do
        render :show
      end
    end
  end

  def downloads
    redirect_to link.url
  end

  protected

  def releases
    ReleasesFinder.new(@project, current_user).execute
  end

  def edit
    respond_to do |format|
      format.html do
        render :edit
      end
    end
  end

  private

  def authorize_update_release!
    access_denied! unless can?(current_user, :update_release, release)
  end

  def authorize_read_release_evidence!
    access_denied! unless Feature.enabled?(:release_evidence, project, default_enabled: true)
    access_denied! unless can?(current_user, :read_release_evidence, release)
  end

  def release
    @release ||= project.releases.find_by_tag!(sanitized_tag_name)
  end

  def link
    release.links.find_by_filepath!(sanitized_filepath)
  end

  def sanitized_filepath
    CGI.unescape(params[:filepath])
  end

  def sanitized_tag_name
    CGI.unescape(params[:tag])
  end
end
