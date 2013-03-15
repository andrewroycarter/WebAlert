WebAlert
========

A ruby script that checks for changes on a given website, and sends sms alerts via email.

Configuration
=============

Edit config.yml to reflect the folling
 * gmail `address` and `password`
 * `website` to poll for changes
 * `message` to send when changes are detected
 * `log` - log results as polling occurs)
 * `interval` - interval to poll for changes
 * array of people `phone` numbers and respective `carrier` to alert

Running
=======
To run, `bundle install` then `bundle exec ruby webalert.rb`. The application will use the given settings
to poll and alert!
