## DB設計
- Skater has many of Competition
- Competition has many of CategoryResults and Scores
- CategoryResults has a Score of short and a Score of free
- Score has many of Elements and Components



## AjaxDatabales

### 基本的な使い方
レコードのテーブル表示。ajax-datatables-rails という module もあるが、使いやすいよう自分で作った。
app/views/application/_datatable.html.slim を予め置いておいて、　

```ruby
AjaxDatatables::Datatable.new(view_context).columns([:name, :value]).records(User.all).render
```

のように使う。UserDecorater を作っていれば、

```ruby
AjaxDatatables::Datatable.new(view_context).columns([:name, :value]).records(User.all).decorator.render
```
とすると呼び出してくれる。

### クラス継承
AjaxDatatables::Datatable から派生すれば専用のを作れる：

```ruby
% cat app/datatables/users_datatable.rb
class UsersDatatable < AjaxDatatables::Datatable
  def initialize(*)
	super
	columns([:name, :value])
  end
  def fetch_records
	User.all
  end
end

% cat app/views/index.html.slim
= UsersDatatable.new(self).render
```

## ActiveHash::Base
便利なのだが、whereが使えない。



## ISUさんしっかりしてくれ

- 日付のフォーマットがバラバラ
- http://www.isuresults.com/results/fc2012/ : Sandra KHOPON と KOHPON とリザルトとスコアで表記が違う
- http://www.pfsa.com.pl/results/1314/WC2013/ : Mairya1 BAKUSHEVA と Mariya と以下同文
- http://www.isuresults.com/results/season1617/gpfra2016/SEG007.HTM がまだLIVE
- http://www.isuresults.com/results/season1718/gpchn2017/SEG003.HTM がまだLIVE
