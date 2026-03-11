class TasksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def powder_check
    auth_token = ENV["CRON_TOKEN"]
    
    if auth_token.blank? || params[:token] != auth_token
      render json: { error: "Unauthorized" }, status: :unauthorized
      return
    end

    # Run the rake task in a separate thread/process to respond quickly
    # but since it's a cron job, a simple system call or Rake task invocation is fine.
    Rails.logger.info "Starting daily powder check via HTTP endpoint..."
    
    begin
      Rails.application.load_tasks
      Rake::Task["powder:check"].invoke
      render json: { status: "success", message: "Powder check started" }, status: :ok
    rescue => e
      Rails.logger.error "Powder check failed: #{e.message}"
      render json: { status: "error", message: e.message }, status: :internal_server_error
    ensure
      # Re-enable the task for the next call in the same process if needed
      Rake::Task["powder:check"].reenable
    end
  end
end
