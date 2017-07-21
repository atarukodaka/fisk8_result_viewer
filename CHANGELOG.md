## TODO
- category: type: single/couple ?

- let/context DRY for filter/order
- property: readonly, writeonly
- expand_data...?
- goe operator, value_operator ajax search
- order, etc ajax settings _datatable.html.slim
- hide/show toggle details

### new feature
- embed youtube in score (or just link to search page ?)

### check before release
- app/controller/application_controller: unless Rails.env.develop
- config/application: Version
- config/competitions.yml: debug

## 1.0.2-pre2
- defer loading
- _datatable rewrite

## 1.0.2-pre1
- sortable list table
- sitemap
- ajax support
- sort in list table
- lib/fisk8viewer moved out
- element type
- parsers controller added
- error handlers moved into concertn
- single data listtable
- show.json w/o builder
- rspec: filter search for all controllers(elements, compoments)
- factorygirls
- default_order
- select options default sort
 - caching
- datatable id: consistency btw ajax_search() and render => settings
- dattatable1.10
- Category: accept
- bretel for breadcrumb
- results controller added
- competition\_class i/o isu_championships
- category_results to results
- elememts: level
- normalize competition name
- results have short\_*, free_\*
- update: Timeout error:  rescue Errno::ETIMEDOUT
- offset for csv/json
- datatable: numbering

## 1.0.1 2017/6/25

## 1.0.1-pre2 2017/6/24
- model create from hash

## 1.0.1-pre1 2017/6/18
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
- deduction reasons
- elements/components-operators
- updater/parser => skater/competition/score
- lib/fisk8viewer => lib/fisk8_result_viewer
- category summary on competition as decorator
- element.element, comoponent.component: name as attr
- element summary: not as db column
- jbuilder for .json
- csv-builder for csv output
- app/views/score/show.html: unsafe youtube link -> escape html
- eliminate feedback
- cid => competition.short_name, sid => score.name
- updater/*, parser/*

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
