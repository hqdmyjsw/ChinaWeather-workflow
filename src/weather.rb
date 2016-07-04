#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'json'
require 'net/http'

# Search china weather
module Weather
  def self.search_weather(query)
    WeatherFetcher.new.search(query)
  end

  # Weather fetcher
  class WeatherFetcher
    def search(query)
      q = query.delete(EX_STRING)
      @city = q.empty? ? take_city : q
      take_weather
    end

    def take_city(default = '未知')
      json = take_json(API_LOCATION)
      city = json.nil? ? default : json['content']['address']
      city = default if city.nil? || city.empty?
      city
    end

    def take_json(uri, is_output_error = false)
      res = Net::HTTP.get_response(URI.parse(uri))
      res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body) : nil
    rescue
      output_error('暂时无法连接到服务器', '请检查网络连接或者稍后再试。', 'ERR') if is_output_error
      nil
    end

    def take_weather
      uri = API_WEATHER + URI.encode_www_form_component(@city)
      json = take_json(uri, is_output_error: true)
      return if json.nil?
      if json['error'] != 0
        output_error
      else
        current_city = json['results'][0]['currentCity']
        pm25 = json['results'][0]['pm25']
        weather_data = json['results'][0]['weather_data']
        output_result(current_city, pm25, weather_data)
      end
    end

    def output_error(title = nil, subtitle = nil, arg_msg = nil)
      title = "未查到“#{@city}”的天气，按回车显示网页结果。" if title.nil?
      subtitle = '提示：若查询北京市天气，请输入：tq 北京 或者 tq beijing' if subtitle.nil?
      arg = take_arg(arg_msg.nil? ? 'WEB' : arg_msg)
      print "<?xml version=\"1.0\"?> \
<items><item arg=\"#{arg}\" valid=\"yes\"> \
<title>#{title}</title> \
<subtitle>#{subtitle}</subtitle> \
<icon>unknown.png</icon> \
</item></items>"
    end

    def output_result(current_city, pm25, weather_data)
      s = ''
      weather_data.each.with_index do |x, i|
        title = x['date']
        subtitle = "#{x['weather']}  #{x['wind']}  #{x['temperature']}"
        icon = take_weather_icon(x['weather'])
        arg = take_arg('OK', "#{current_city} #{x['date']} #{x['weather']} #{x['wind']} #{x['temperature']}")
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

    def take_weather_icon(keyword)
      output = ICONS[keyword]
      if output.nil?
        ICONS.each do |key, value|
          if keyword.include?(key)
            output = value
            break
          end
        end
      end
      output || 'unknown.png'
    end

    def take_arg(msg, info = '')
      [msg, @city, info].join('|') # msg: OK/WEB/ERR
    end
  end
end

API_WEATHER = 'http://api.map.baidu.com/telematics/v3/weather?output=json&ak=Gy7SGUigZ4HxGYDaq9azWy09&location='.freeze
API_LOCATION = 'http://api.map.baidu.com/location/ip?ak=ZmjUrFm4QT13mrgUrHcYXRIt'.freeze
EX_STRING = "<>'\"& \n\t\r;#".freeze
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
