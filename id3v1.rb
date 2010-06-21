#!/usr/bin/env ruby
# Simple implementation of ID3v1 based on the spec found at
# http://en.wikipedia.org/wiki/ID3

# ToDo includes: ID3v1 extended, making it have write capacity, making
# it a gem, including genre constants, and more

class ID3v1
        attr_reader :title, :artist, :album, :year, :comment, :genre
        def initialize(filename)
                begin
                        # Read in the file as a byte stream
                        file = File.open(filename, "rb")
                        bytes = file.read

                        tag = bytes[-128,3]
                        if (tag != "TAG")
                                raise "ID3 Tags Not Present."
                        end

                        @title   = bytes[-125, 30].strip # -128 + 3
                        @artist  = bytes[-95, 30].strip # -128 + 33
                        @album   = bytes[-65, 30].strip # -128 + 63
                        @year    = bytes[-35, 4].strip # -128 + 93
                        @comment = bytes[-31, 30].strip # -128 + 97
                        @genre   = bytes[-1, 1].strip # -128 + 127
                rescue => err
                        puts err
                        exit
                ensure
                        file.close
                end
        end
end
