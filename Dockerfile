FROM ruby:2.3.1-alpine

MAINTAINER izumin5210 <masayuki@izumin.info>

ENV WORKDIR /app
RUN mkdir $WORKDIR
WORKDIR $WORKDIR

ARG run_at=50\t23\t*\t*\t*\t

RUN apk add --update --virtual build-dependencies \
        g++ \
        make \
        tzdata \
    && apk add \
        musl-dev \
        libstdc++ \
    && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && printenv | sed 's/^\(.*\)$/export \1/g' | grep -e "GEM" -e "BUNDLE" >> /root/.profile \
    && echo -e "$run_at . /root/.profile; cd $(pwd); $(which ruby) reporter.rb" >> /var/spool/cron/crontabs/root

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install -j4

RUN apk del build-dependencies \
    && rm -rf /var/cache/apk/*

COPY . .

RUN cat /var/spool/cron/crontabs/root

CMD ["crond", "-l", "2", "-f"]
