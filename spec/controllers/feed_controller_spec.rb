require 'rails_helper'

RSpec.describe FeedController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }

    context 'when logged in with followed users' do
      let(:followed) { create(:user) }
      let!(:their_post) { create(:post, user: followed) }
      let!(:other_post) { create(:post) }

      before do
        log_in(user)
        create(:follow, follower: user, followed:)
      end

      it 'returns 200' do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it 'shows only posts from followed users' do
        get :index
        expect(assigns(:posts)).to include(their_post)
        expect(assigns(:posts)).not_to include(other_post)
      end
    end

    context 'when logged in but following nobody' do
      before { log_in(user) }

      it 'shows all posts' do
        post1 = create(:post)
        post2 = create(:post)
        get :index
        expect(assigns(:posts)).to include(post1, post2)
      end
    end

    context 'with tag filter' do
      let!(:tag)     { create(:tag) }
      let!(:match)   { create(:post) }
      let!(:no_match) { create(:post) }

      before do
        log_in(user)
        PostTag.create!(post: match, tag:)
      end

      it 'filters posts by tag_ids' do
        get :index, params: { 'tag_ids[]' => [tag.id] }
        expect(assigns(:posts)).to include(match)
        expect(assigns(:posts)).not_to include(no_match)
      end
    end

    context 'with text search' do
      before { log_in(user) }

      it 'filters posts by title' do
        match    = create(:post, title: 'Ruby on Rails guide')
        no_match = create(:post, title: 'Cooking recipes')
        get :index, params: { q: 'Rails' }
        expect(assigns(:posts)).to include(match)
        expect(assigns(:posts)).not_to include(no_match)
      end

      it 'filters posts by body' do
        match    = create(:post, body: 'This is about Docker containers')
        no_match = create(:post, body: 'This is about cooking')
        get :index, params: { q: 'Docker' }
        expect(assigns(:posts)).to include(match)
        expect(assigns(:posts)).not_to include(no_match)
      end
    end

    context 'when not logged in' do
      it 'returns 200 and shows all posts' do
        post1 = create(:post)
        get :index
        expect(response).to have_http_status(:ok)
        expect(assigns(:posts)).to include(post1)
      end
    end
  end

  describe 'GET #discover' do
    it 'returns 200' do
      get :discover
      expect(response).to have_http_status(:ok)
    end

    it 'assigns up to 30 posts' do
      create_list(:post, 35)
      get :discover
      expect(assigns(:posts).size).to be <= 30
    end

    context 'with tag filter' do
      let!(:tag)      { create(:tag) }
      let!(:match)    { create(:post) }
      let!(:no_match) { create(:post) }

      before { PostTag.create!(post: match, tag:) }

      it 'filters by tag' do
        get :discover, params: { tag_ids: [tag.id] }
        expect(assigns(:posts)).to include(match)
        expect(assigns(:posts)).not_to include(no_match)
      end
    end

    context 'with text search' do
      it 'filters by query' do
        match    = create(:post, title: 'TypeScript tips')
        no_match = create(:post, title: 'Gardening basics')
        get :discover, params: { q: 'TypeScript' }
        expect(assigns(:posts)).to include(match)
        expect(assigns(:posts)).not_to include(no_match)
      end
    end
  end
end
