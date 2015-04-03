module Api
  module Ncr
    class UsersController < ApplicationController
      def index
        users = User.all

        if params[:limit]
          users = users.limit(params[:limit].to_i)
        end
        if params[:offset]
          users = users.offset(params[:offset].to_i)
        end

        render json: users, root: false, each_serializer: FullUserSerializer
      end
    end
  end
end
