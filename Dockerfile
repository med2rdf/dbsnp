FROM ruby:2.5

ADD . /dbsnp-rdf/

COPY docker-entrypoint.sh /

WORKDIR /dbsnp-rdf

RUN rm -rf .bundle && \
    bundle install

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dbsnp-rdf", "--help"]
