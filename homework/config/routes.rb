Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'index#index'
  get '/code' => 'code#code',as:'code_check'
  get '/code_check' => 'code#code_check',as:'code_checked'
  get '/yarv' => 'byte#yarv',as:'yarv'
  get '/byte_yarv' => 'byte#byte_yarv',as:'yarvka'
  get '/blog' => 'blog#random',as:'random'
  get '/recommend' => 'blog#recommend',as:'recommend'
end
