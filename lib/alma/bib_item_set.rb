module Alma
  class BibItemSet
    extend Forwardable

    # Let BibItemSet respond to the Enumerable duck type
    # by delegating responsibility for #each to items
    include Enumerable
    attr_accessor :items
    def_delegators :items, :each

    def_delegators :items,:[], :[]=, :empty?, :size

    attr_reader :raw_response, :total_record_count
    def_delegators :raw_response, :response, :request

    def initialize(response)
      @raw_response = response
      parsed = JSON.parse(response.body)
      @total_record_count = parsed["total_record_count"]
      @items = parsed.fetch("item",[]).map {|item| BibItem.new(item)}
    end

    def grouped_by_library
      group_by(&:library)
    end

    def filter_missing_and_lost
      clone = dup
      clone.items = reject(&:missing_or_lost?)
      clone
    end
  end
end