class TagsController < ApplicationController
  def show
    @tag = Tag.find_by!(name: params[:name])
  end

  # GET /tags/search?q=ruby — JSON cu sugestii
  def search
    q = params[:q].to_s.strip.downcase
    tags = q.present? ? Tag.where('name LIKE ?', "%#{q}%").order(:name).limit(10) : Tag.order(:name).limit(10)
    render json: tags.map { |t| { id: t.id, name: t.name } }
  end
end
