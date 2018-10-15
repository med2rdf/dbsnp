FROM ruby:2.5

RUN apt-get update && \
  apt-get install -y libraptor2-dev && \
  rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /

ADD . /dbsnp-rdf/

WORKDIR /dbsnp-rdf

RUN rm -rf .bundle && \
  bundle install

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dbsnp-rdf", "--help"]
