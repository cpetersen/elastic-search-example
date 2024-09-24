class Page < ApplicationRecord
  searchkick searchable: [ :title, :body ]
end
