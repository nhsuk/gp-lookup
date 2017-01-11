# GP Lookup

A small experiment in building a GP lookup that's simple to use.

## Development

Getting started:

 - Install Ruby 2.2.3
 - `bundle install`

Starting up the server:

    ALLOWED_ORIGINS=http://localhost:3000 bundle exec rackup

## Usage

The only endpoint is `/practices`. You can search by including a query
parameter: `/practices?search=lake+side`.

## Updating data

Get new data from the [general-medical-practices][practices] and
[general-medical-practitioners][practitioners] repos:

    curl https://raw.githubusercontent.com/nhsuk/general-medical-practices/master/output/general-medical-practices.json > data/general-medical-practices.json
    curl https://raw.githubusercontent.com/nhsuk/general-medical-practitioners/master/output/general-medical-practitioners.json > data/general-medical-practitioners.json
    git add data/general-medical-{practices,practitioners}.json
    git commit --message "Updated practice and practitioner data"

[practices]: https://github.com/nhsuk/general-medical-practices
[practitioners]: https://github.com/nhsuk/general-medical-practitioners
