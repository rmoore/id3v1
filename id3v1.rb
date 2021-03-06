#!/usr/bin/env ruby
# Simple implementation of ID3v1 based on the spec found at
# http://en.wikipedia.org/wiki/ID3

require "genre"

class ID3v1
	attr_reader :title, :artist, :album, :year, :comment, :genre

	def initialize(filename)
		# Read in the file as a byte stream
		@file = File.open(filename, "r+b")
		@file.seek(-128, IO::SEEK_END)
		bytes = @file.read(128)

		parse_id3(bytes)
	end

	def close
		@file.close
	end

	def has_id3?
		@tag == "TAG"
	end

	def title=(tag)
		ensure_id3

		# Ensure the tag is stripped and padded to 30 bytes.
		data = tag[0, 30].ljust(30, 0.chr)
		
		# Write the tag to the file
		write_data_at_offset(-125, data)

		# Update the reader
		@title = data.strip
	end

	def artist=(tag)
		ensure_id3

		# Ensure the tag is stripped and padded to 30 bytes.
		data = tag[0, 30].ljust(30, 0.chr)

		# Write the tag to the file.
		write_data_at_offset(-95, data)

		# Update the reader
		@artist = data.strip
	end

	def album=(tag)
		ensure_id3

		# Ensure the tag is stripped and padded to 30 bytes.
		data = tag[0, 30].ljust(30, 0.chr)

		# Write the tag to the file.
		write_data_at_offset(-65, data)

		# Update the reader
		@album = data.strip
	end

	def year=(tag)
		# This might have to be redone so it is overloaded for various
		# year notations (string, int, Date, etc...) For now, we will
		# do a .to_s to ensure we have a string.

		ensure_id3	

		# Ensure the tag is stripped and padded to 4 bytes. (Year in
		# string notation YYYY).
		data = tag.to_s[0, 4].ljust(4, 0.chr)

		# Write the tag to the file.
		write_data_at_offset(-35, data)

		# Update the reader.
		@year = data.strip
	end

	def comment=(tag)
		ensure_id3

		# Ensure the tag is stripped and padded to 30 bytes.
		data = tag[0, 30].ljust(30, 0.chr)

		# Write the tag to the file.
		write_data_at_offset(-31, data)

		# Update the reader
		@comment = data.strip
	end

	def genre=(tag)
		# make sure that we are getting 1 byte.
		raise ArgumentError, "Invalid Arg" if tag.to_i < 0
		raise ArgumentError, "Invalid Arg" if tag.to_i > 255
		
		ensure_id3
		
		# Convert data to single char.
		data = tag.to_i.chr

		# Write the tag to the file.
		write_data_at_offset(-1, data)

		# Update the reader
		@genre = data.strip
	end
		
	private
	def parse_id3( data )
		# Ensure we get 128 bytes, this is the only correct size for
		# a valid id3 tag.
		raise ArgumentError, "Wrong Tag Size" unless data.length == 128

		# If we have tag, parse the data, otherwise it gets set to 
		# blank.
		@tag = data[0, 3]
		if @tag == "TAG"
			@title   = data[3,  30].strip
			@artist  = data[33, 30].strip
			@album   = data[63, 30].strip
			@year    = data[93,  4].strip
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

	def ensure_id3
		if not has_id3?
			# Generate an empty tag.
			data = "TAG".ljust(128, 0.chr)

			# Append it to the end of the file.
			@file.seek(0, IO::SEEK_END)
			@file << data
		end
	end

	# This function will write `data` at `offset` from the end of the file.
	def write_data_at_offset(offset, data)
		@file.seek(offset.to_i, IO::SEEK_END)
		@file << data
	end
end
