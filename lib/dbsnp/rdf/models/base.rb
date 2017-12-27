require 'active_record'
require 'activerecord-import'
require 'rdf'
require 'rdf/vocab'

module Dbsnp
  module RDF
    module Models
      class Base < ActiveRecord::Base

        CONFIG = { encoding: 'unicode',
                   adapter:  'postgresql',
                   host:     'localhost',
                   pool:     5,
                   database: 'dbsnp',
                   username: 'postgres',
                   password: nil }.freeze

        self.abstract_class = true

        establish_connection(CONFIG)

        def self.create_database
          ActiveRecord::Base.establish_connection(CONFIG.merge({ database: 'postgres' }))
          ActiveRecord::Base.connection.create_database(CONFIG[:database])

          ActiveRecord::Base.clear_all_connections!
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

              t.index :rs, unique: true
            end

            create_table :alleles do |t|
              t.column :report_id, :integer, null: false
              t.column :ref, :string
              t.column :alt, :string

              t.index :report_id
            end

            create_table :frequencies do |t|
              t.column :report_id, :integer, null: false
              t.column :frequency, :float
              t.column :allele, :string
              t.column :sample_size, :integer

              t.index :report_id
            end

            create_table :builds do |t|
              t.column :report_id, :integer, null: false
              t.column :chr, :integer, null: false
              t.column :position, :integer, null: false
              t.column :refseq, :string, null: false

              t.index :report_id
            end

            create_table :hgvs_names do |t|
              t.column :report_id, :integer, null: false
              t.column :name, :string

              t.index :report_id
            end

            create_table :significances do |t|
              t.column :report_id, :integer, null: false
              t.column :name, :string

              t.index :report_id
            end
          end
        end

        def self.drop_database
          Dbsnp::RDF::Models::Base.clear_all_connections!

          ActiveRecord::Base.establish_connection(CONFIG.merge({ database: 'postgres' }))
          ActiveRecord::Base.connection.drop_database(CONFIG[:database])

          # Dbsnp::RDF::Models::Base.clear_all_connections!
          # ActiveRecord::Base.clear_all_connections!
          #
          # raise("Cannot remove #{CONFIG[:database]}") unless File.file?(CONFIG[:database])
          #
          # FileUtils.rm(CONFIG[:database], force: true, verbose: true)
        end

      end
    end
  end
end
