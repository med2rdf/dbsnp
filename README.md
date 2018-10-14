# DbSNP::RDF

## Usage

- Input: dbSNP VCF (Variant Call Format)

  - GRCh37
    ftp://ftp.ncbi.nlm.nih.gov/snp/.redesign/latest_release/VCF/GCF_000001405.25.bgz
  - GRCh38
    ftp://ftp.ncbi.nlm.nih.gov/snp/.redesign/latest_release/VCF/GCF_000001405.33.bgz

- Output: Turtle formatted RDF

### With docker

```
$ docker build --tag dbsnp-rdf .
$ zcat GCF_000001405.33.vcf.bgz | docker run --rm -i dbsnp-rdf dbsnp-rdf convert | gzip -c > dbSNP.GRCh38.ttl.gz
```

### In your code

```ruby
require 'dbsnp/rdf'

DbSNP::RDF::Writer::Turtle.new do |writer| # to standard output
  DbSNP::RDF::Reader::VCF.new.each do |data| # from standard input
    writer << data
  end
end

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/med2rdf/dbsnp-rdf. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dbsnp::Rdf project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/med2rdf/dbsnp-rdf/blob/master/CODE_OF_CONDUCT.md).
