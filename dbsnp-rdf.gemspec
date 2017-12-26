lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dbsnp/rdf/version'

Gem::Specification.new do |spec|
  spec.name    = 'dbsnp-rdf'
  spec.version = Dbsnp::RDF::VERSION
  spec.authors = ['Daisuke Satoh']
  spec.email   = ['daisuke.satoh@level-five.jp']

  spec.description = 'RDF Converter for dbSNP'
  spec.summary     = spec.description
  spec.homepage    = "TODO: Put your gem's website or public repo URL here."
  spec.license     = 'MIT'

  spec.files = Dir['exe/*'] + Dir['lib/**/*.rb'] + Dir['[A-Z]*']
  spec.files.reject! { |fn| fn.include? "CVS" }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print', '~> 1.8'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'activerecord', '~> 5.1'
  spec.add_dependency 'nokogiri', '~> 1.8'
  spec.add_dependency 'rdf-turtle', '~> 2.2'
  spec.add_dependency 'rdf-vocab', '~> 2.2'
  spec.add_dependency 'ruby-progressbar', '~> 1.9'
  spec.add_dependency 'sqlite3', '~> 1.3'
end
