module EventsHelper
	 def category_class(event)
  	e = event
  	category = ""
  	e['categories']['category'].each do |i|
      i.each do |j,k|
        category = event['categories']['category']['id'] if !k 
        category = "#{category} #{k} " if j == "id" 
      end 
    end 
    puts category
  return category
  end
end
