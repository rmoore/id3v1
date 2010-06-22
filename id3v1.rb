#!/usr/bin/env ruby
# Simple implementation of ID3v1 based on the spec found at
# http://en.wikipedia.org/wiki/ID3

require "genre"

class ID3v1
        attr_reader :title, :artist, :album, :year, :comment, :genre
        def initialize(filename)
                begin
                        # Read in the file as a byte stream
                        file = File.open(filename, "rb")
			file.seek(-128, IO::SEEK_END)
                        bytes = file.read
			
			parse_id3(bytes)

                rescue => err
                        puts err
                        exit
                ensure
                        file.close
                end
        end

	def has_id3?
		@tag == "TAG"
	end

	private
	def parse_id3( data )
		# Ensure we get 128 bytes, this is the only correct size for
		# a valid id3 tag.
		raise SyntaxError, "Wrong Tag Size" unless data.length == 128

		# If we have tag, parse the data, otherwise it gets set to 
		# blank.
		@tag = data[0, 3]
		if @tag == "TAG"
			@title   = data[3, 30].strip
			@artist  = data[33, 30].strip
			@album   = data[63, 30].strip
			@year    = data[93, 4].strip
			@comment = data[97, 30].strip
			@genre   = data[127, 1].strip
		else
			@title   = ""
			@artist  = ""
			@album   = ""
			@year    = ""
			@comment = ""
			@genre   = ""
		end
	end
end
