#name

require "sqlite3"
require "nokogiri"
require "open-uri"

#schema
# programers
# => name
# => url 
# => tagline
# => id
# content
# => id
# => programmer_id
# => type
# => text





wiki_start_page = "http://en.wikipedia.org/wiki/List_of_programmers"
doc = Nokogiri::HTML(open(wiki_start_page))

programers = (doc/"#mw-content-text li")

i = 0
programers.each do |page_name| 
	next if !page_name.first_element_child
	next if !page_name.first_element_child.key?("href")

	full_url = "http://en.wikipedia.org" + page_name.first_element_child['href']
	doc = Nokogiri::HTML(open(full_url))

	tag = page_name.inner_text 
	name = (doc/"#firstHeading span").inner_text
	content = (doc/"#toc ul li a")
	content_headers = content.map { |header| header["href"] }
	content = (doc/"#mw-content-text")
	content_hash = {}
	content.children.each do |tag|
		 if tag.matches?("h2")
		 	content_hash[key] = field_content if key
		 	field_content = ""
		 	key = tag.children[2]["id"].to_sym
		 end
		 field_content << tag.inner_text if tag.matches?("p")

	end
	break
	
end


