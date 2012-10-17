#name

require "sqlite3"
require "nokogiri"
require "open-uri"
require 'FileUtils'

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
FileUtils.rm("programmers.db") if File.exists?("programmers.db")

db = SQLite3::Database.new "programmers.db"

statment = <<SQL
	CREATE TABLE programmers (
		id INTEGER PRIMARY KEY,
		name varchar(255),
		tag varchar(255),
		url varchar(255)
		);
SQL
db.execute(statment)
statment = <<SQL 
		CREATE TABLE contents (
		id INTEGER PRIMARY KEY,
		programmer_id INTEGER,
		type varchar(255),
		text varchar(255)
		);
SQL
db.execute(statment)


class Programer
	attr_accessor :id, :name, :tag, :url, :content
	def initialize(id,name,tag,url,content)
		@id = id
		@name = name
		@tag = tag
		@url = url
		@content = content
	end
	def save(db)
		db.execute("INSERT INTO programmers (name, tag, url) 
            VALUES (?, ?, ?)", [@name, @tag, @url])

		@content.each_pair do |type,text|
			db.execute("INSERT INTO contents (programmer_id,type,text) 
	            VALUES (?, ?, ?)", [@programmer_id,type,text]) if !text.empty? 
		end
		true
	end
end


wiki_start_page = "http://en.wikipedia.org/wiki/List_of_programmers"
doc = Nokogiri::HTML(open(wiki_start_page))

pages = (doc/"#mw-content-text li")
id = 0

programmer_list = pages.map do |page_name| 
	next if !page_name.first_element_child
	next if !page_name.first_element_child.key?("href")

	full_url = "http://en.wikipedia.org" + page_name.first_element_child['href']
	doc = Nokogiri::HTML(open(full_url))

	tag = page_name.inner_text 
	name = (doc/"#firstHeading span").inner_text

	content = (doc/"#mw-content-text")
	content_hash = {}
	field_content = ""
	key = nil
	content.children.each do |tag|
		 if tag.matches?("h2")
		 	content_hash[key] = field_content if key
		 	field_content = ""
		 	key = tag.children.search("span").inner_text
		 end
		 field_content << tag.inner_text if tag.matches?("p")
	end
	Programer.new(id,name,tag,full_url,content_hash)
end

programmer_list.each {|e| e.save(db)}


