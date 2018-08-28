== DB設計
- Skater has many of Competition
- Competition has many of CategoryResults and Scores
- CategoryResults has many of Scores (SP, FS)
- Score has many of Elements and Components

CategoryResult.short, CategoryResult.free と持たせようと思ったが、表示でN+1問題が起こってしまうのでやめ。


== AjaxDatabales

ajax-datatables-rails という mod もあるが、
