#!/usr/bin/env ruby

#####################################
# by dshaw, 7/29/11
# console.fm is a great way to find new
# music -- this way, you can download
# the playlists and listen to them
# even when you're offline!
#####################################

require "open-uri"
require 'optparse'


# _ _ ._  _ _ | _ _|_._ _  (_ / |_) /\\ |_)|_
#(_(_)| |_>(_)|(/_o| | | | __)\\_| \\/--\\|  |_
#
#usage: ruby console-fm-scrape.rb <genre>

categories = [
	"Top (default)",
	"Breaks",
	"Chill-out",
	"Deep-house",
	"Drum-and-bass",
	"Dubstep",
	"Electro-house",
	"Electronica",
	"Funk-r-and-b",
	"Glitch-Hop",
	"Hard-dance",
	"Hardcore-hard-techno",
	"Hip-hop",
	"House",
	"Indie-dance-nu-disco",
	"Minimal",
	"Pop-rock",
	"Progressive-house",
	"Psy-trance",
	"Reggae-dub",
	"Tech-house",
	"Techno",
	"Trance"
]


######### TINY BIT OF CONFIG #########
options = {}
options [:verbose] = false
options [:category] = "top"
options [:directory] = "./music-downloads"
options [:list] = false

OptionParser.new do |opts|
	opts.banner = "Usage: %s [options]" % $0

	opts.on("-v", "--verbose", "Run verbosely") do 
	  options[:verbose] = true
	end

	opts.on("-c", "--category [CATEGORY]", "use [category]. Default is top") do |c|
	  options[:category] = c
	end

	opts.on("-d", "--directory [DIRECTORY]", "download to [directory]") do |d|
	  options[:directory] = d
	end
 
	opts.on("-l", "--list [CATEGORY]", "list songs before downloading them. Lists categories if no argument is supplied") do |l|
	  options[:list] = l || true
	end

end.parse!


if options[:verbose] == true then
	puts "verbose"
end

# checks for existence of download directory
if not File.directory?(options[:directory]) then
	puts "[!] download directory #{options[:directory]} does not exist!"
	puts "[!] please create it before running!"
	Kernel.exit
end

# print list of categories if user wants to
if options[:list] == true then
	puts "Current available playlists include:"
	categories.each do |category|
		puts category
	end
	Kernel.exit
end

target = "http://console.fm/#{options[:category]}"
puts "[+] trying to reach #{target}"

open(target) do |p|
	p.each_line do |line|
		if line =~ /http:\/\/media.console.fm\/tracks\/\d+/
			location = $&
			line =~ /\">(.*)\</
			name = $1[0..-5]
			name.gsub!(/\//, '_')
			fname = "#{options[:directory]}/#{name}.mp3"

			print "[+] grabbing track #{name}..."

			if not File.exists?(fname)
				f = File.new(fname, "wb")
			begin
				f.write(open(location, "Cookie" => p.meta['set-cookie']).read)
			rescue
				print "ERROR \n"
				File.delete(fname)
				next
			end
				f.close
			print "done \n"
			sleep (5) # sleep 10-20 seconds
			else
				print "exists \n"
			end
		end
  	end
end

puts "[+] script completed"
