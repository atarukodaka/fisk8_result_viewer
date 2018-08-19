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
```

on development,

```sh
% bundle exec rake db:migrate
```

on production,
```sh
% bundle exec rake assets:precompile
% bundle exec rake secret
% export SECRET_KEY_BASE=.....
```

### Usage
```sh
% bundle exec rake update:skaters
% bundle exec rake update:competitions
% bundle exec rails server
```

If you want to add new competition(s), edit config/competitions.yml and run updates.

## Maintain competitions list

Add site url of competitions that you want to add into 'config/competitions.yml' and run 'rake update'. see the file for details.


## Demonstration
this package is running here: [Fisk8 Result Viewer](http://tk2-201-10287.vs.sakura.ne.jp/fisk8viewer).
