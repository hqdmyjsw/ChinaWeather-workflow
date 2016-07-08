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
      # for debug weather icon
      if query && query.length > 1 && query[0] == '.'
        debug_search_icon(query.delete('.' << EX_STRING))
        return
      end
      # search weather
      q = query.delete(EX_STRING)
      @city = q.empty? ? take_city : q
      take_weather
    end

    def take_city(default: '未知')
      json = take_json(API_LOCATION)
      city = json && json['content']['address']
      city = default if city.nil? || city.empty?
      city
    end

    def take_json(uri, is_output_error: false)
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
        r = json['results'][0]
        output_result(r['currentCity'], r['pm25'], r['weather_data'])
      end
    end

    def output_error(title = "未查到“#{@city}”的天气，按回车显示网页结果。",
                     subtitle = '提示：若查询北京市天气，请输入：tq 北京 或者 tq beijing',
                     arg_msg = 'WEB',
                     icon = UNKNOWN_ICON)
      print '<?xml version="1.0"?><items><item arg="' << take_arg(arg_msg) <<
            '" valid="yes"><title>' << title << '</title><subtitle>' <<
            subtitle << '</subtitle><icon>' << icon << '</icon></item></items>'
    end

    def output_result(current_city, pm25, weather_data)
      items = ''
      weather_data.each.with_index do |x, i|
        title = x['date']
        subtitle = '' << x['weather'] << '  ' << x['wind'] <<
                   '  ' << x['temperature']
        icon = take_weather_icon(x['weather'])
        arg = take_arg('OK', '' << current_city << ' ' << x['date'] <<
            ' ' << x['weather'] << ' ' << x['wind'] << ' ' << x['temperature'])
        if i == 0
          title << '  ' << current_city
          unless pm25.nil? || pm25.empty?
            subtitle << '  PM2.5: ' << pm25
            arg << ' PM2.5: ' << pm25
          end
        end
        items << '<item arg="' << arg << '" valid="yes"><title>' <<
          title << '</title><subtitle>' << subtitle <<
          '</subtitle><icon>' << icon << '</icon></item>'
      end
      print '<?xml version="1.0"?><items>' << items << '</items>'
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
      output || UNKNOWN_ICON
    end

    def take_arg(msg, info = '')
      [msg, @city, info].join('|') # msg: OK/WEB/ERR/ICON
    end

    # for debug show weather icon
    def debug_search_icon(keyword)
      @city = keyword # to arg: ICON|keyword
      icon = take_weather_icon(keyword)
      output_error('查看“' << keyword << '”的天气图标，按回车显示网页搜索结果',
                   '例子: 输入 tq .晴 可显示晴天图标。', 'ICON', icon)
    end
  end
end

API_WEATHER = 'http://api.map.baidu.com/telematics/v3/weather?output=json&ak=Gy7SGUigZ4HxGYDaq9azWy09&location='.freeze
API_LOCATION = 'http://api.map.baidu.com/location/ip?ak=ZmjUrFm4QT13mrgUrHcYXRIt'.freeze
EX_STRING = "<>'\"& \n\t\r;#".freeze
UNKNOWN_ICON = 'a9.png'.freeze
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
