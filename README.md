[![Build Status](https://travis-ci.org/atarukodaka/fisk8_result_viewer.svg?branch=master)](https://travis-ci.org/atarukodaka/fisk8_result_viewer)
[![codecov](https://codecov.io/gh/atarukodaka/fisk8_result_viewer/branch/master/graph/badge.svg)](https://codecov.io/gh/atarukodaka/fisk8_result_viewer)
[![Code Climate](https://codeclimate.com/github/atarukodaka/fisk8_result_viewer/badges/gpa.svg)](https://codeclimate.com/github/atarukodaka/fisk8_result_viewer)

## Overview
Result and Score viewer of figureskating competitions. you can see below details of competitions you registered:

- score and its details (ex. element/component details)
- competitions (only ISU competitions supported)
- skaters info (incl. ISU bio info)


## Install

```sh
% sudo yum -y install poppler-utils
% bundle install
% bundle exec rake db:migrate
% bundle exec rake update_skaters
% bundle exec rake update_competitions
% bundle exec rails server
```

#### on production

```sh
% bundle exec rake assets:precompile
% bundle exec rake secret
% export SECRET_KEY_BASE=.....
```

and run migrate, update and server upon RACK_ENV=production.

## Maintain competitions list

Add site url of competitions that you want to add into 'config/competitions.yaml' and run 'rake update'. see the file for details.


## Demonstration
this package is running here: [Fisk8 Result Viewer](http://tk2-201-10287.vs.sakura.ne.jp/fisk8viewer).
