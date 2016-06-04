# Hitorigoto Reporter

## Usage
Execute:

```
$ bundle install
```

And then run this app:

```
$ ruby reporter.rb
```


## Configure
Add your configuration to `.env` file in the root of your project:

```
SLACK_ACCESS_TOKEN="your-slack-access-token"
SLACK_TARGET_CHANNELS="hitorigoto-syaro;hitorigoto-cocoa;hitorigoto-chino;hitorigoto-rize;hitorigoto-chiya"
ESA_ACCESS_TOKEN="your-esa-access-token"
ESA_CURRENT_TEAM="your-esa-team"
ESA_REPORT_CATEGORY="日報/%Y/%m/%d"
```

## LICENSE
Licensed under [MIT License](https://izumin.mit-license.org/2016).
