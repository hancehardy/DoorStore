class UserSerializer
  include JSONAPI::Serializer
  attributes :email, :id, :created_at
end
