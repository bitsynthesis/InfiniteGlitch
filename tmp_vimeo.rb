require 'net/http'

if ARGV.size < 1
    puts "usage vimeo.rb <id_video>"
    exit 1
else
    id = ARGV[0]
    Net::HTTP.start('www.vimeo.com') {|http|
       	req = Net::HTTP::Get.new("/moogaloop/load/clip:#{id}", nil)
       	response = http.request(req)
       	/(.*)<\/caption>/.match(response.body)
	title = $1
	/(.*)<\/request_signature>/.match(response.body)
	signature = $1
	/(.*)<\/request_signature_expires>/.match(response.body)
	signatureExp = $1
	req = Net::HTTP::Get.new("/moogaloop/play/clip:#{id}/#{signature}/#{signatureExp}/?q=hd", nil)
	http.request(req) { |response|
            puts response['location']                  # to deal with Permanent or temporary redirect :)
	   /(mp4|flv)/.match(response['location'])
	   ext = $1
	   /http:\/\/(.*\.vimeo\.com)(\/.*)/.match(response['location'])
	   Net::HTTP.start($1) {|http|
		req = Net::HTTP::Get.new($2)
		http.request(req) { |response|
                     File.open("#{title}.#{ext}",'w') {|f|
                        f.write(response.body)
                     }
		}
	   }
	}	
    }
end

