class YouTubeInspiration
  def thumbnail
    "http://i.ytimg.com/vi/#{video_id}/default.jpg"
  end
  
  def embedded
    %{
      <object width="425" height="344">
        <param name="movie" value="http://www.youtube.com/v/#{video_id}&hl=en&fs=1&rel=0&autoplay=1"></param>
        <embed src="http://www.youtube.com/v/#{video_id}&hl=en&fs=1&rel=0"
               type="application/x-shockwave-flash"
               allowfullscreen="true"
               width="425"
               height="344">
        </embed>
      </object>
    }
  end
end