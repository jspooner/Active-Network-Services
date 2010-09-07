Active
    by Jonathan Spooner and Brian Levine
    http://developer.active.com/docs/Activecom_Search_API_Reference

== DESCRIPTION:

Search api for Active Network

== FEATURES/PROBLEMS:

* Seach API

== SYNOPSIS:

	Search.search( {:location => "San Diego, CA, US"} )

	List all categories
	Active::Services::Search.CHANNELS.each do |key, value| 
		puts key.to_s.humanize
	end 
	
	

== REQUIREMENTS:

* none

== INSTALL:

* sudo gem install Active

== LICENSE:

(The MIT License)

Copyright (c) 2010 Active Network

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
