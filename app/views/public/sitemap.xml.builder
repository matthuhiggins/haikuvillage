xml.instruct!
xml.urlset( :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") {
  xml.url {
    xml.loc "http://www.haikuvillage.com"
    xml.lastmod @last_haiku.created_at.strftime("%Y-%m-%d")
    xml.changefreq "daily"
  }
  
  xml.url {
    xml.loc "http://www.haikuvillage.com/about"
    xml.changefreq "monthly"
  }
  
  xml.url {
    xml.loc "http://www.haikuvillage.com/haikus"
    xml.lastmod @last_haiku.created_at.strftime("%Y-%m-%d")
    xml.changefreq "daily"
  }
  
  xml.url {
    xml.loc "http://www.haikuvillage.com/authors"
    xml.changefreq "daily"
  }
}
