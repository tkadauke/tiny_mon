task :assets do
  icons = %w(success failure offline)
  icons += (0..5).to_a.collect { |i| "weather-#{i}" }
  
  icons.each do |icon|
    sh "convert -resize 40x40 app/assets/images/icons/original/#{icon}.png app/assets/images/icons/large/#{icon}.png"
    sh "convert -resize 20x20 app/assets/images/icons/original/#{icon}.png app/assets/images/icons/small/#{icon}.png"
  end
end
