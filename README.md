# ChinaWeather-workflow
An Alfred workflow that can search china weather.

<img src="ChinaWeather_1.png" width="500" />

<img src="ChinaWeather_2.png" width="500" />

### 说明

* 根据[@wensonsmith](https://github.com/wensonsmith)的[Baidu Weather](https://github.com/wensonsmith/weather-workflow)用 Ruby 2.0 重写创建
* 优化图标显示。新图标来自[橘色天气预报PNG图标 - 懒人图库](http://www.lanrentuku.com/png/1522.html)
* 天气查询和查询IP所在城市的API来自百度车联网
* 可设置默认城市：在`Alfred Preferences`的`Workflows`页中选择`China weather`，双击右侧的`tq`Script Filter，取消注释行（删除 # 符号），然后用你希望的城市名替换`北京`。如果注释掉这行，会查询IP地址所在城市作为默认城市。

### 使用

* 从Release或者Tags下载[`China weather.alfredworkflow`](https://github.com/m2nlight/ChinaWeather-workflow/releases/download/v0.1.2.2
/China.weather.alfredworkflow)，双击或者用 Alfred 打开导入到 Workflows
* 在 Alfred 中输入 `tq` 会显示当前IP地址所在城市的天气情况（可在tq里修改成默认城市）
* 输入`tq 上海`或者`tq shanghai`可显示上海天气
* 在显示天气结果上按`return`，会复制天气信息到剪贴板
* 在查询失败结果上按`return`，会用默认的Web浏览器打开百度的搜索结果页面
* 在结果中按`command＋return`，会用默认的Web浏览器打开百度的搜索结果页面
