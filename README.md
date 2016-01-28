# GP Lookup

A small experiment in building a GP lookup that's simple to use.

## Development

Getting started:

 - Install Ruby 2.2.3
 - `bundle install`

Starting up the server:

    bundle exec rackup

## Usage

The only endpoint is `/practices`. You can search by including a query
parameter: `/practices?search=lake+side`.

## Updating data

Get new data from the [general-medical-practices][gmp] repo:

    curl https://raw.githubusercontent.com/nhsalpha/general-medical-practices/master/output/general-medical-practices.json > data/general-medical-practices.json
    git add data/general-medical-practices.json
    git commit --message "Updated practice data"

[gmp]: https://github.com/nhsalpha/general-medical-practices
