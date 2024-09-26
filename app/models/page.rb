class Page < ApplicationRecord
  searchkick word_start: [ :title, :body ]
end
