FROM ruby:2.3.1-alpine

MAINTAINER izumin5210 <masayuki@izumin.info>

ENV WORKDIR /app
RUN mkdir $WORKDIR
WORKDIR $WORKDIR

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
    && echo -e "$run_at . /root/.profile; cd $(pwd); $(which ruby) main.rb" >> /var/spool/cron/crontabs/root

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install -j4 \
    && apk del build-dependencies \
    && rm -rf /var/cache/apk/*

COPY . .

CMD ["crond", "-l", "2", "-f"]
