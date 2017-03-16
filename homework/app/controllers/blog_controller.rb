require 'matrix'

def open_each_ss(file)
  open(file) do |f|
    f.each do |row|
      begin
        yield row
      rescue
        p 'invalid string'
      end
    end
  end
end

class BlogController < ApplicationController
  def random
    @dum = "dumdum"
    @display = Hash.new
    @numbers = Array.new
    titles = Array.new
    urls = Array.new

    # タイトルの把握
    titles = Array.new()
    File.open("#{Rails.root}/app/data/titles.txt","r") do |f|
      while title = f.gets do
        titles << title.chomp.to_s
      end
    end

    # url の把握
    urls = Array.new()
    File.open("#{Rails.root}/app/data/url.txt","r") do |file|
      while url = file.gets do
        urls << url.chomp.to_s
      end
    end

    4.times do
      num = rand(662)
      @numbers << num
      @display[titles[num]] = urls[num]
    end

    render action: :random
  end

  def recommend
    @num = params[:blog_num].to_i
    @display = Hash.new
    @numbers = Array.new
    titles = Array.new
    urls = Array.new

    # タイトルの把握
    titles = Array.new()
    File.open("#{Rails.root}/app/data/titles.txt","r") do |f|
      while title = f.gets do
        titles << title.chomp.to_s
      end
    end

    # url の把握
    urls = Array.new()
    File.open("#{Rails.root}/app/data/url.txt","r") do |file|
      while url = file.gets do
        urls << url.chomp.to_s
      end
    end

    data = File.read("#{Rails.root}/app/data/vec.dat")
    vectors = Marshal.load data

    # vectors の添え字を変えることでリコメンド元が変更可能 0 ~ 661
    vec = Vector.elements(vectors[@num])
    max_score = Array.new(4, {score: 0, index: 0, title: "", url: ""})

    vectors.each_with_index do |vector, index|
      # ベクトルの内積の和を計算し保存
      score = vec.inner_product(Vector.elements(vector)).fdiv(vec.norm * Vector.elements(vector).norm)
      max_score.sort! {|a, b| a[:score] <=> b[:score] }
      # スコアが高い場合は更新
      if max_score[0][:score] < score
        max_score.shift
        # max_score.push({score: score, index: index})
        max_score.push({score: score, index: index,title: titles[index], url: urls[index]})
      end
    end
    p max_score
    max_score.each do |ary|
      @display[ary[:title]] = ary[:url]
      @numbers << ary[:index]
    end

    render action: :random
  end
end
