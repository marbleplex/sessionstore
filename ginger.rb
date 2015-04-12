#!ruby
# -*- coding: utf-8 -*-
#  ported from https://github.com/naoya/perl-Ginger/

class Ginger

  require 'open-uri'
  require 'cgi'
  require 'uri'
  require 'json'
  
  def initialize
    @api_key = '6ae0c3a0-afdc-4532-a810-82ded0054236'
    @base_url = 'http://services.gingersoftware.com/Ginger/correct/json/GingerTheText?'
  end

  def usage
    puts "#{File.basename(__FILE__)} sentence. (words of sentence are combined with %20"
  end
  
  def prepare_src_text(*argv)
    @orig_text = argv.join(' ')
    @query_text = CGI.escape(@orig_text)
  end

  def to_s
    result = JSON(@result_json)
    pp json unless result
    gr = result['LightGingerTheTextResult']
    text = @orig_text.dup
    gap = 0
    gr.each do |r|
      # r['Confidence']
      from = r['From']
      to   = r['To']
      suggest = r['Suggestions'][0]['Text']
      to -= from if to
      text[from + gap, to + 1] = suggest
      gap += suggest.length - 1 - to
    end
    "original   : #{@orig_text}
recomended : #{text}"
  end

  def gingeration(*argv)
    prepare_src_text(argv)
    uri = URI(@base_url)
    uri.query = "lang=US&clientVersion=2.0&apiKey=#{@api_key}&text=#{@query_text}"
    ua = 'Mozilla/5.0 (Windows NT 5.1; rv:37.0) Gecko/20100101 Firefox/37.0'
    @result_json = open(uri, {"User-Agent" => ua}).read
    pp @result_json if $DEBUG
    puts to_s
  end
end

g = Ginger.new
g.gingeration(ARGV)
