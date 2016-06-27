#!usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'json'
require 'net/http'

# Search china weather
class Weather
  @city = ''
  def search_weather(query) # rubocop:disable Metrics/MethodLength
    query = query.delete(EXSTRING)
    @city = query.empty? ? search_location : query
    # request data
    uri = API_WEATHER + URI.encode_www_form_component(@city)
    resp = Net::HTTP.get_response(URI.parse(uri))
    json = JSON.parse(resp.body)
    if json['error'] != 0
      output_error
    else
      current_city = json['results'][0]['currentCity']
      pm25 = json['results'][0]['pm25']
      weatherdata = json['results'][0]['weather_data']
      output_result(current_city, pm25, weatherdata)
    end
  end

  def search_location
    uri = API_LOCATION
    resp = Net::HTTP.get_response(URI.parse(uri))
    json = JSON.parse(resp.body)
    address = json['content']['address']
    address
  end

  def output_result(current_city, pm25, weatherdata) # rubocop:disable Metrics/MethodLength
    s = ''
    weatherdata.each.with_index do |x, i|
      title = x['date']
      subtitle = "#{x['weather']}  #{x['wind']}  #{x['temperature']}"
      icon = take_weather_icon(x['weather'])
      arg = "#{current_city} #{x['date']} #{x['weather']} #{x['wind']} #{x['temperature']}"
      if i == 0
        title += "  #{current_city}"
        unless pm25.empty?
          subtitle += "  PM2.5: #{pm25}"
          arg += " PM2.5: #{pm25}"
        end
      end
      s += "<item arg=\"#{arg}\" valid=\"yes\"> \
<title>#{title}</title> \
<subtitle>#{subtitle}</subtitle> \
<icon>#{icon}</icon></item>"
    end
    print "<?xml version=\"1.0\"?><items>#{s}</items>"
  end

  def output_error
    print "<?xml version=\"1.0\"?> \
<items> \
<item arg=\"https://www.baidu.com/s?wd=#{@city}天气\" valid=\"yes\"> \
<title>未查到“#{@city}”的天气，按回车显示网页结果。</title> \
<subtitle>提示：若查询北京市天气，请输入：tq 北京 或者 tq beijing</subtitle> \
<icon>unknown.png</icon> \
</item></items>"
  end

  def take_weather_icon(keyword)
    output = ICONS[keyword]
    if output.nil?
      ICONS.each do |key, value|
        if keyword.include? key
          output = value
          break
        end
      end
    end
    output.nil? ? 'unknown.png' : output
  end

  private :search_location, :output_result, :output_error, :take_weather_icon
end

API_WEATHER = 'http://api.map.baidu.com/telematics/v3/weather?output=json&ak=Gy7SGUigZ4HxGYDaq9azWy09&location='.freeze
API_LOCATION = 'http://api.map.baidu.com/location/ip?ak=ZmjUrFm4QT13mrgUrHcYXRIt'.freeze
EXSTRING = "<>'\"& \n\t\r;#".freeze
ICONS = {
  '雾霾' => 'haze.png',
  '霾' => 'haze.png',
  '大雾' => 'fog.png',
  '雾' => 'mist.png',
  '大暴雪' => 'snow5.png',
  '暴雪' => 'snow4.png',
  '大雪' => 'snow3.png',
  '中雪' => 'snow2.png',
  '小雪' => 'snow1.png',
  '阵雪' => 'snow1.png',
  '冰雹' => 'hail.png',
  '雨夹雪' => 'sleet.png',
  '雷阵雨转暴雨' => 'tstorm3.png',
  '雷阵雨转大雨' => 'tstorm3.png',
  '雷阵雨转中雨' => 'tstorm2.png',
  '雷阵雨' => 'tstorm1.png',
  '暴雨' => 'shower3.png',
  '大雨' => 'shower3.png',
  '中雨' => 'shower2.png',
  '小雨' => 'shower1.png',
  '阵雨' => 'shower1.png',
  '雨' => 'light_rain.png',
  '阴' => 'overcast.png',
  '多云' => 'cloudy5.png',
  '阴转晴' => 'cloudy4.png',
  '多云转晴' => 'cloudy4.png',
  '晴转多云' => 'cloudy3.png',
  '晴见多云' => 'cloudy1.png',
  '晴' => 'sunny.png'
}.freeze
