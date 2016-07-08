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
      case msg # OK/WEB/ERR/ICON
      when 'OK'
        copy_to_clipboard(info)
      when 'WEB'
        open_web_page(city)
      when 'ICON'
        # for debug, the city is weather name
        open_web_search("#{city} 图标")
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
      open_web_search("#{city}天气")
    end

    def open_web_search(keyword)
      uri = WEB_BAIDU_SEARCH + keyword
      system('open', uri)
    end
  end
end

WEB_BAIDU_SEARCH = 'https://www.baidu.com/s?wd='.freeze
