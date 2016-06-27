# ChinaWeather-workflow
An Alfred workflow that can search china weather.

<img src="ChinaWeather_1.png" width="500" />

<img src="ChinaWeather_2.png" width="500" />

### 说明

* 根据[@wensonsmith](https://github.com/wensonsmith)的[Baidu Weather](https://github.com/wensonsmith/weather-workflow)用 Ruby 2.0 重写创建
* 优化图标显示。图标来自[橘色天气预报PNG图标 - 懒人图库](http://www.lanrentuku.com/png/1522.html)
* 天气查询API来自百度车联网
* 打开China weather Workflow，双击tq Script Filter，取消注释行，指定城市名，可替换通过IP获取城市的方式查询默认天气

### 使用

* 下载`ChinaWeather.alfredworkflow`，双击或者用 Alfred 打开导入到 Workflow
* 在 Alfred 中输入 `tq` 会显示当前IP地址所在城市的天气情况
* 输入`tq 上海`或者`tq shanghai`可显示上海天气
* 在显示天气结果上按回车键，会复制天气信息到剪贴板
* 在查询失败结果上按回车键，会用默认的Web浏览器打开百度的搜索结果页面
