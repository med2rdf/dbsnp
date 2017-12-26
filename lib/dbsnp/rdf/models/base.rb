require 'active_record'
require 'rdf'
require 'rdf/vocab'

module Dbsnp
  module RDF
    module Models
      class Base < ActiveRecord::Base

        CONFIG = { adapter:  'sqlite3',
                   database: './temp.db' }.freeze

        self.abstract_class = true

        establish_connection(CONFIG)

        def self.create_database
          ActiveRecord::Base.establish_connection(CONFIG)

          ActiveRecord::Schema.define do
            create_table :reports do |t|
              t.column :rs, :integer, null: false

              # snp, in-del, heterozygous, microsatellite, named-locus,
              # no-variation, mixed, multinucleotide-polymorphism
              t.column :snp_class, :string, null: false

              # notwithdrawn, artifact, gene-duplication, duplicate-submission,
              # notspecified, ambiguous-location, low-map-quality
              t.column :snp_type, :string, null: false

              # genomic, cDNA, mito, chloro, unknown
              t.column :mol_type, :string, null: false

              t.column :tax, :integer, null: false

              t.column :significance, :string
            end

            create_table :alleles do |t|
              t.column :report_id, :integer, null: false
              t.column :ref, :string
              t.column :alt, :string
            end

            create_table :frequencies do |t|
              t.column :report_id, :integer, null: false
              t.column :frequency, :float
              t.column :allele, :string
              t.column :sample_size, :integer
            end

            create_table :builds do |t|
              t.column :report_id, :integer, null: false
              t.column :chr, :integer, null: false
              t.column :position, :string, null: false
              t.column :refseq, :string, null: false
            end

            create_table :hgvs_names do |t|
              t.column :report_id, :integer, null: false
              t.column :name, :string
            end
          end
        end

        def self.drop_database
          Dbsnp::RDF::Models::Base.clear_all_connections!
          ActiveRecord::Base.clear_all_connections!

          raise("Cannot remove #{CONFIG[:database]}") unless File.file?(CONFIG[:database])

          FileUtils.rm(CONFIG[:database], force: true, verbose: true)
        end

      end
    end
  end
end
