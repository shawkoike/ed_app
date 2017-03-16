class CodeController < ApplicationController
  def code_check
    @title = "ヒント"
    @code = params[:code]
    @msg = Array.new

    # for check_line
    $arrow = 0
    # スタート　終わりを表す count
    $count_if = 0
    $count_end = 0
    $start_if = Array.new
    $end_if = Array.new
    # 行数を指定するため
    line_num = 1
    # 全体のための状態
    $status_for_all = 'normal'
    # クラス定義の中かどうか
    $status_for_class = 0
    # def の数
    $the_number_of_def = 0
    # end の数
    $the_number_of_end = 0
    # if , end , elsif の数
    $the_number_of_if = 0
    $the_number_of_elsif = 0
    $the_number_of_ifend = 0
    # コメントの数
    $the_number_of_comment = 0
    # 全体のメソッドの数
    $the_number_of_method = 0
    # クラス内のメソッドの数
    $the_number_of_method_in_class = 0
    # メソッド def の数
    $the_number_of_def_method = Hash.new

    # どのメソッドに飛ばすべきか分別するメソッド
    def check_line(line,line_number)
      if (line[0]=='#' && $status_for_all=='normal') || line=~/\#/
        # check_comment
        $arrow = 1
      elsif (line[0]=='c' && line[1]=='l' && line[2]=='a' && line[3] == 's' && line[4] == 's') || $status_for_all=='in_class'
        # check_class
        $arrow = 2
      elsif (line[0]=='d' && line[1]=='e' && line[2]=='f')
        # check_method
        $arrow = 3
      elsif (line[0]=='i' && line[1]=='f')
        $start_if[$count_if] = line_number
        $the_number_of_if += 1
        $count_if += 1
      elsif (line[0]=='e' && line[1]=='l' && line[2]=='s' && line[3]=='i' && line[4]=='f')
        $the_number_of_elsif += 1
      elsif (line[0]=='e' && line[1]=='n' && line[2]=='d')
        $end_if[$count_end] = line_number
        $the_number_of_ifend += 1
        $count_end += 1
        if($the_number_of_if == $the_number_of_ifend)
          @msg << "#{$start_if.shift}〜#{$end_if.pop}行目 : 条件分岐が多すぎます case文を使いましょう" if $the_number_of_elsif > 5
          @msg <<  "#{$start_if.shift}〜#{$end_if.pop}行目 : ネストが深すぎます" if $the_number_of_if > 3
          $the_number_of_if = 0
          $the_number_of_elsif = 0
          $the_number_of_ifend = 0
          $start_if = []
          $end_if = []
          $count_if = 0
          $count_end = 0
        end
      elsif (line =~ /\"/)
        # check_double_quoto
        $arrow = 4
      end
    end

    # コメントのフォーマットをチェックするメソッド arrow:1
    def check_comment(line,line_number)
      /#/ =~ line
      $the_number_of_comment += 1
      @msg << "#{line_number}行目 : コメントチェック"
      @msg << "　　空白がない" unless $'[0] == ' '
      if line =~ /[^ -~｡-ﾟ]/
        @msg << "　　全角でのコメントは避けましょう"
      else
        # @msg << "　　半角で書かれている"
      end
      $arrow = 0
    end

    # クラス関連のチェック arrow:2
    def check_class(line,line_number)
      # クラス名のチェック
      if line =~ /class/
        $class_name = $'.strip
        if ($'[1]=='h' && $'[2]=='o' && $'[3]=='g' && $'[4]=='e') || ($'[1]=='f' && $'[2]=='o' && $'[3]=='o') || ($'.size == 2)
          @msg << "#{line_number}行目 : クラス名には意味をもたせましょう"
        end
      end

      puts "#{line_number} : in class"
      $status_for_all = 'in_class'
      $the_number_of_def += 1 if line[0]=='d' && line[1]=='e' && line[2]=='f'
      $the_number_of_end += 1 if line[0]=='e' && line[1]=='n' && line[2]=='d'

      # クラス定義の終了
      if ($the_number_of_end-$the_number_of_def) == 1
        if $the_number_of_method_in_class > 5
          @msg << "#{$class_name} : class 内のメソッドは極力少なくしましょう"
          $the_number_of_method_in_class = 0
        end
        $status_for_all = 'normal'
        $the_number_of_def = 0
        $the_number_of_end = 0
        $arrow = 0
      end

      # クラス内のコメントチェック  追加の必要
      if line[0] == '#'
        check_comment(line,line_number)
      end
      # メソッド定義
      if line =~ /def/
        $the_number_of_method_in_class += 1
        # メソッドの名前について
        if ($'[1]=='h' && $'[2]=='o' && $'[3]=='g' && $'[4]=='e') || ($'[1]=='f' && $'[2]=='o' && $'[3]=='o') || ($'[2] == '(') || ($'.size == 2)
          @msg << "#{line_number}行目 : 関数名には意味をもたせましょう"
        end
      end
      # クラス内の " " のチェック
      if line =~ /\"/
        check_double_quoto(line,line_number)
      end
    end

    # メソッド名のチェック $arrow:3
    def check_method(line,line_number)
      $the_number_of_method = 0
      if line =~ /def/
        # 引数なしメソッドの名前について
        if ($'[1]=='h' && $'[2]=='o' && $'[3]=='g' && $'[4]=='e') || ($'[1]=='f' && $'[2]=='o' && $'[3]=='o') || ($'[2] == '(') || ($'.size == 2)
          @msg << "#{line_number}行目 : 関数名には意味をもたせましょう"
        end
      end
      $arrow = 0
    end

    # ' ' と " " の使い分け $arrow:4
    def check_double_quoto(line,line_number)
      @msg << "#{line_number}行目 : 式展開のないダブルコーテーションは避けましょう" unless /\#/ =~ line
      $arrow = 0
    end

    # main
    # 対象ファイルの指定
    text = @code
    begin
      text.each_line do |line|
        # 行の空白文字を削除
        line.strip!
        check_line(line,line_num)
        case $arrow
        when 0 then
          # @msg << "#{line_num} : 特に問題ない"
        when 1 then
          check_comment(line,line_num)
        when 2 then
          check_class(line,line_num)
        when 3 then
          check_method(line,line_num)
        when 4 then
          check_double_quoto(line,line_num)
        end
        line_num += 1
      end
    # 例外処理
    rescue SystemCallError => e
      puts e
    rescue IOError => e
      puts e
    end

     @msg << "コメントを増やしましょう" if $the_number_of_comment == 0
    render action: :code
  end

end
