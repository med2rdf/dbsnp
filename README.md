# dbSNP::RDF

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
$ zcat GCF_000001405.33.vcf.bgz | docker run --rm -i dbsnp-rdf dbsnp-rdf convert 2> dbSNP.GRCh38.ttl.log | gzip -c > dbSNP.GRCh38.ttl.gz
```

### On your system

See [Prerequisites](#prerequisites) before running the code. 

```
$ git clone https://github.com/med2rdf/dbsnp.git
$ cd dbsnp
$ bundle install
$ zcat GCF_000001405.33.vcf.bgz | bundle exec dbsnp-rdf convert 2> dbSNP.GRCh38.ttl.log | gzip -c > dbSNP.GRCh38.ttl.gz 
```

or in your ruby code

```ruby
require 'dbsnp/rdf'

DbSNP::RDF::Writer::Turtle.new do |writer| # to standard output
  DbSNP::RDF::Reader::VCF.new.each do |data| # from standard input
    writer << data
  end
end

```

#### Prerequisites 

- ruby 2.5.0+
- (Optional) [raptor 2.0+](http://librdf.org/raptor/)

Note: In macOS, the raptor library installed with Homebrew is NOT applicable for now.
Please build the library from source following the below instruction.

##### Install raptor (Optional)

apt

```
# apt-get update && apt-get install libraptor2
```

yum

```
# yum install raptor2
```

from source

```
$ wget http://download.librdf.org/source/raptor2-2.0.15.tar.gz
$ tar xvf raptor2-2.0.15.tar.gz
$ cd raptor2-2.0.15
$ ./configure --disable-debug --disable-dependency-tracking
$ make
(switch to super user if needed)
# make install
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/med2rdf/dbsnp-rdf. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dbsnp::Rdf project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/med2rdf/dbsnp-rdf/blob/master/CODE_OF_CONDUCT.md).
