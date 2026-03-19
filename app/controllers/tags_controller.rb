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

  # POST /tags — creează un tag nou dacă nu există
  def create
    require_login!
    name = params[:name].to_s.strip.downcase.gsub(/[^[:word:]]/, '')
    return render json: { error: 'Nume invalid' }, status: :unprocessable_entity if name.blank?

    tag = Tag.find_or_create_by(name:)
    render json: { id: tag.id, name: tag.name }, status: :ok
  end
end
