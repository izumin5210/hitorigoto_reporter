# Hitorigoto Reporter

## Usage
Execute:

```
$ bundle install
```

And then run this app:

```
$ ruby main.rb
```

Or when you use docker:

```
$ docker-compose up
```


## Configure
Add your configuration to enviromnent variables:

```
export SLACK_ACCESS_TOKEN="your-slack-access-token"
export SLACK_TARGET_CHANNELS="hitorigoto-syaro;hitorigoto-cocoa;hitorigoto-chino;hitorigoto-rize;hitorigoto-chiya"
export ESA_ACCESS_TOKEN="your-esa-access-token"
export ESA_CURRENT_TEAM="your-esa-team"
export ESA_REPORT_CATEGORY="日報/%Y/%m/%d"
```

## LICENSE
Licensed under [MIT License](https://izumin.mit-license.org/2016).
