require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user) }

  describe 'GET #my_posts' do
    context 'when logged in' do
      before { log_in(user) }

      it 'returns 200' do
        get :my_posts
        expect(response).to have_http_status(:ok)
      end

      it 'assigns only current user posts' do
        own   = create(:post, user: user)
        other = create(:post)
        get :my_posts
        expect(assigns(:posts)).to include(own)
        expect(assigns(:posts)).not_to include(other)
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        get :my_posts
        expect(response).to redirect_to(log_in_path)
      end
    end
  end

  describe 'GET #liked_posts' do
    context 'when logged in' do
      before { log_in(user) }

      it 'returns 200' do
        get :liked_posts
        expect(response).to have_http_status(:ok)
      end

      it 'assigns posts liked by current user' do
        liked   = create(:post)
        unliked = create(:post)
        create(:like, post: liked, user: user)
        get :liked_posts
        expect(assigns(:posts)).to include(liked)
        expect(assigns(:posts)).not_to include(unliked)
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        get :liked_posts
        expect(response).to redirect_to(log_in_path)
      end
    end
  end

  describe 'POST #create' do
    context 'when logged in' do
      before { log_in(user) }

      it 'creates a post and redirects to feed' do
        expect {
          post :create, params: { post: { title: 'New Post', body: 'Some body', tag_ids: [] } }
        }.to change { Post.count }.by(1)
        expect(response).to redirect_to(feed_path)
      end

      it 'renders new on invalid params' do
        post :create, params: { post: { title: '', body: '' } }
        expect(response).to render_template(:new)
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        post :create, params: { post: { title: 'T', body: 'B' } }
        expect(response).to redirect_to(log_in_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'as post owner' do
      before { log_in(user) }

      it 'deletes the post' do
        post_record
        expect { delete :destroy, params: { id: post_record.id } }
          .to change { Post.count }.by(-1)
      end

      it 'redirects to feed' do
        delete :destroy, params: { id: post_record.id }
        expect(response).to redirect_to(feed_path)
      end
    end

    context 'as another user' do
      let(:other) { create(:user) }
      before { log_in(other) }

      it 'does not delete the post and redirects to feed' do
        post_record
        delete :destroy, params: { id: post_record.id }
        expect(response).to redirect_to(feed_path)
        expect(Post.exists?(post_record.id)).to be true
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        delete :destroy, params: { id: post_record.id }
        expect(response).to redirect_to(log_in_path)
      end
    end
  end

  describe 'POST #toggle_like' do
    context 'when logged in' do
      before { log_in(user) }

      it 'likes a post' do
        expect {
          post :toggle_like, params: { id: post_record.id }
        }.to change { Like.count }.by(1)
      end

      it 'unlikes an already liked post' do
        create(:like, post: post_record, user: user)
        expect {
          post :toggle_like, params: { id: post_record.id }
        }.to change { Like.count }.by(-1)
      end

      it 'returns json with liked status' do
        post :toggle_like, params: { id: post_record.id }
        json = JSON.parse(response.body)
        expect(json['liked']).to be true
        expect(json['likes_count']).to eq(1)
      end
    end

    context 'when not logged in' do
      it 'returns 401 for JSON requests' do
        post :toggle_like, params: { id: post_record.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
