FROM ruby:2.3.1-alpine

MAINTAINER izumin5210 <masayuki@izumin.info>

ENV PROJECT /project
ENV APP $PROJECT/app
RUN mkdir -p $APP
WORKDIR $PROJECT

ARG run_at=0\t2\t*\t*\t*\t

RUN apk add --update --virtual build-dependencies \
        g++ \
        make \
    && apk add \
        libstdc++ \
        musl-dev \
        openssl \
        tzdata \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && printenv | sed 's/^\(.*\)$/export \1/g' | grep -e "GEM" -e "BUNDLE" >> /root/.profile \
    && echo -e "$run_at . /root/.profile; cd $APP; $(which ruby) main.rb" >> /var/spool/cron/crontabs/root

RUN mkdir -p lib/hitorigoto_reporter
COPY Gemfile .
COPY Gemfile.lock .
COPY hitorigoto_reporter.gemspec .
COPY lib/hitorigoto_reporter/version.rb lib/hitorigoto_reporter

WORKDIR $APP
COPY sample/Gemfile .
COPY sample/Gemfile.lock .

RUN bundle install -j4 \
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/*

COPY lib ../lib
COPY sample .

CMD ["crond", "-l", "2", "-f"]
