
## TODO

- parser は　dev のときだけe
- deviatino メニューは flag on のときだけ
- competitions.conf は年ごと分ける？
- timeschedules を conf に
- season_skipper はやめるかな

## DB設計
- Skater has many of Competition
- Competition has many of CategoryResults and Scores
- CategoryResults has a Score of short and a Score of free
- Score has many of Elements and Components

## 使い方

```
be rake update:skater
be rake update:competitions last=10 force=1 enable_judge_details=1 season_from=2012-13
be rake update:competition site_url=http://www..../wc2017
```

- last: competitions.yaml の下から指定した分だけ
- force: 真だと存在してもアップデート、偽ならスキップ
- enable_judge_detials: 個別ジャッジ・逸脱度の集計（時間とDB食う）
- season_from, season_to: 対象シーズン

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
### ..
- ajax 使う場合は DB カラムを作る必要あり
- 文字列を返すカラムであること

### 複数モデル

- 他のモデルを参照する場合は、対応する virtual method を用意し、N+1を防ぐため includes する
- ajax を使う場合は columns[key].source でテーブル名とフィールド名を指定し、かつ joins する

```ruby
% cat app/models/score.rb
def score
  ...
  delegate :competition_class, to: competition

% cat app/datatables/scores_datatable.rb
  def initialize(*)
    super
	columns([........, :competition_type,....])
	columns[:competition_type].source = 'competitions.competition_type'

  def fetch_records
    super.joins(:competition).includes(:competition)
```

### datatable の仕組み
- .html:
- .json/.csv:


## メモ
### ActiveHash::Base
便利なのだが、whereが使えない。

### Capybara
- js: true にしないと js driver が動いてくれない。
- JAVASCIRPT_DRIVER=chrome で立ち上げると chrome が表で動く

### postgres
edit config/database.yml

```
sudo /etc/init.d/postgresql start
sudo update-rc.d postgresql defaults
sudo -u postgres createuser -d -P fisk8viewer
Password: xxx
sudo -u postgres dropdb fisk8viewer
sudo -u postgres createdb fisk8viewer -O fisk8viewer

export DATABASE_PASSWORD=****
export DATABASE_HOST=localhost
RAILS_ENV=production bundle exec rake db:reset
RAILS_ENV=production bundle exec rake update:skaters
RAILS_ENV=production bundle exec rake update:competitions

```
### heroku

```
heroku login
(herokuの設定で github の repository と連携するようにする）
git push origin master
#git remote add heroku git@heroku.com:fisk8-result-viewer.git
#git push heroku master
sudo -u postgres createuser -s `whoami` （これしとかないと role '***' does not exist が出る）
heroku pg:reset --confirm fisk8-result-viewer
heroku pg:push fisk8viewer DATABASE_URL
heroku restart
```

## ISUさんしっかりしてくれ

- 日付のフォーマットがバラバラ
- http://www.isuresults.com/results/fc2012/ : Sandra KHOPON と KOHPON とリザルトとスコアで表記が違う
- http://www.pfsa.com.pl/results/1314/WC2013/ : Mairya1 BAKUSHEVA と Mariya と以下同文
- http://www.isuresults.com/results/season1617/gpfra2016/SEG007.HTM がまだLIVE
- http://www.isuresults.com/results/season1718/gpchn2017/SEG003.HTM がまだLIVE
- http://www.kraso.sk/wp-content/uploads/sutaze/2014_2015/20141001_ont/html/index.htm PAIRエントリーないのにリザルトページはある（だけどテーブルは無し）
