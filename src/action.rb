# result to action
module Action
  def self.run(query)
    Actor.new.run(query)
  end

  def self.run_web(query)
    Actor.new.run_web(query)
  end

  # Actor
  class Actor
    def run(query)
      msg, city, info = query.split('|')
      case msg # OK/WEB/ERR
      when 'OK'
        copy_to_clipboard(info)
      when 'WEB'
        open_web_page(city)
      end
    end

    def run_web(query)
      city = query.split('|')[1]
      open_web_page(city)
    end

    def copy_to_clipboard(info)
      IO.popen('pbcopy', 'w') { |f| f << info }
    end

    def open_web_page(city)
      uri = WEB_BAIDU_FORMAT % city
      system('open', uri)
    end
  end
end

WEB_BAIDU_FORMAT = 'https://www.baidu.com/s?wd=%s天气'.freeze
