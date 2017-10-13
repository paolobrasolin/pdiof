# coding: utf-8

require 'hexapdf'

def arrange_pages(document:, page_indices:)
  all_pages = document.pages.to_a
  new_page_tree = document.add(Type: :Pages)
  page_indices.each do |index|
    page = all_pages[index]
    page.value.update(page.copy_inherited_values)
    # page.delete(:Rotate)
    new_page_tree.add_page(page)
  end
  document.catalog[:Pages] = new_page_tree
  remove_unused_pages document: document
  document.pages.add unless document.pages.count > 0
end

def remove_unused_pages(document:)
  retained = document.pages.each_with_object({}) {|page, h| h[page.data] = true}
  retained[document.pages.root.data] = true
  document.each(current: false) do |obj|
    next unless obj.kind_of?(HexaPDF::Dictionary)
    if (obj.type == :Pages || obj.type == :Page) && !retained.key?(obj.data)
      document.delete(obj)
    end
  end
end

def find_potential_matches(document:)
  potential_matches = {}
  document.pages.each do |page|
    page.resources[:Font]&.each do |font_resource_name, font|
      integral_codes = font.encoding.code_to_name.select { |_, name| %i{integraltext integraldisplay}.include? name }.keys
      if integral_codes.any?
        potential_matches[page.index] = {}
        potential_matches[page.index][font_resource_name] = integral_codes
      end
    end
  end
  potential_matches
end

def find_matching_pages(document:, potential_matches:)
  matching_pages = []
  document.pages.each do |page|
    next unless potential_matches.keys.include? page.index
    matches = []
    potential_matches[page.index].each do |font, codes|
      codes.each do |code|
        regexp = /\/#{font.to_s} [^\[]*? \[[^\]]*?#{code.to_i.chr}[^\[]*?\]TJ/
        matches.concat page.contents.scan(regexp)
      end
    end
    matching_pages << page.index if matches.any?
  end
  matching_pages
end

################################################################################

document = HexaPDF::Document.open ARGV[0]

potential_matches =
  find_potential_matches document: document

matching_pages =
  find_matching_pages document: document,
                      potential_matches: potential_matches

puts <<~MESSAGE
  Found occurrences of ∫ on pages #{matching_pages.map { |i| i + 1 }} of #{ARGV[0]}.
  Saving them to #{ARGV[1]}...
MESSAGE

arrange_pages document: document,
              page_indices: matching_pages

document.write ARGV[1]

