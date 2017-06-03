## TODO
- re-consider parsers/* system
- http://www.figureskatingresults.fi/results/1415/CSFIN2014/ : charset="unicode" doesnt work
- element.element, comoponent.component: name ?
- app/views/score/show.html: unsafe youtube link

### new feature

- embed youtube in score (or just link to search page ?)


## 1.0.1
- rake update:skaters..name space for update
- autoload fisk8viewer/parsers/*.rb
- competition_summary_parser. use column
- competitions.yml: attributes to symbol keys
- http 404 error rescue on parsing/updating
- challenger: finlandia, aci, nebelhorn, lombaridai, warsaw
- gnuplot: show score graph in skater
- credit downcase
- date default 1970/1/1
- isu championships only on scores
- skater: highest score
- wtt2017: sp/fs ranking
- link to youtube on score
- open-url-redirections
- delete isu_generic_mdy parser; in-corpolated into generic parser
- score-graph: error no year on no scores

## 1.0.0

## 1.0.0-pre4
- decorator.headers
- %3.2f, %d for showing table data
- spec:
  - all filters to work


## 1.0.0-pre3
- elements/show.csv should include scores key
- total base_value in score
- scores.total_bv, total_goe
  - score_parser recognize total base value
- score controler: competitions.season to check
- competition comment
- content_for on <title>
- skater-name correction


## 1.0.0-pre2

## 1.0.0-pre1
- pre-release
