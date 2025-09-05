# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: e.message }, status: :not_found
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end
end
