require 'rails_helper'

RSpec.describe FollowsController, type: :controller do
  let(:alice) { create(:user) }
  let(:bob)   { create(:user) }

  describe 'POST #create' do
    context 'when logged in' do
      before { log_in(alice) }

      it 'creates a follow' do
        expect { post :create, params: { id: bob.id } }
          .to change { Follow.count }.by(1)
      end

      it 'redirects back to the user profile' do
        post :create, params: { id: bob.id }
        expect(response).to redirect_to(user_path(bob))
      end

      it 'does not follow the same user twice' do
        create(:follow, follower: alice, followed: bob)
        expect { post :create, params: { id: bob.id } }
          .not_to change { Follow.count }
      end

      it 'cannot follow yourself' do
        expect { post :create, params: { id: alice.id } }
          .not_to change { Follow.count }
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        post :create, params: { id: bob.id }
        expect(response).to redirect_to(log_in_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when logged in' do
      before do
        log_in(alice)
        create(:follow, follower: alice, followed: bob)
      end

      it 'destroys the follow' do
        expect { delete :destroy, params: { id: bob.id } }
          .to change { Follow.count }.by(-1)
      end

      it 'redirects to the user profile' do
        delete :destroy, params: { id: bob.id }
        expect(response).to redirect_to(user_path(bob))
      end
    end

    context 'when not logged in' do
      it 'redirects to login' do
        delete :destroy, params: { id: bob.id }
        expect(response).to redirect_to(log_in_path)
      end
    end
  end
end
