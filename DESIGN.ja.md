## DB設計
- Skater has many of Competition
- Competition has many of CategoryResults and Scores
- CategoryResults has a Score of short and a Score of free
- Score has many of Elements and Components




## AjaxDatabales

レコードのテーブル表示。ajax-datatables-rails という module もあるが、使いやすいよう自分で作った。


## ISUさんしっかりしてくれ

- 日付のフォーマットがバラバラ
- http://www.isuresults.com/results/fc2012/ : Sandra KHOPON と KOHPON とリザルトとスコアで表記が違う
- http://www.pfsa.com.pl/results/1314/WC2013/ : Mairya1 BAKUSHEVA と Mariya と以下同文
- http://www.isuresults.com/results/season1617/gpfra2016/SEG007.HTM がまだLIVE
- http://www.isuresults.com/results/season1718/gpchn2017/SEG003.HTM がまだLIVE
