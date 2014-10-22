class StaticPagesController < ApplicationController

  CATEGORIES = 'music,comedy,sports'
  CITY ='10009'
  
  def home
    @date = 'Future'
    get_eventful(@date)
    make_map(@events)
  end

  def today
    @date = 'Today'
    get_eventful(@date)
    make_map(@events)
  end

  def this_week
    @date = "This Week"
    get_eventful(@date)
    make_map(@events)
  end  

  def about
    @has_many_data = AppStats.get_has_many_relationships
    @lines_of_code = AppStats.get_lines_of_code
    @files_by_lines_of_code = AppStats.sort_by_lines_of_code

    respond_to do |format|
      format.html
      format.csv do
          headers['Content-Disposition'] = "attachment; filename=\"app_stats\""
          headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def contact
  end

  def load_more_results()
    eventful = Eventful::API.new ENV["EVENTFUL_API_KEY"]
    @result = eventful.call 'events/search',
              :category => get_categories,
              :location => get_location,
              :within => 10,
              :date => params['search_date'],
              :image_sizes => 'perspectivecrop290by250',
              :sort_order => 'popularity',
              :page_size => 10,
              :include => 'categories',
              :page_number => params['page_number']
      @events = @result['events']['event']
      #@test = params[:name]
  end

  def get_current_location
    @hello ='Hellod'
    @lat = params['latitude']
    @long = params['longitude']
    session[:current_location] = "#{@lat},#{@long}"
    redirect_to root_path
  end

  private
  def get_eventful(date=nil)
    begin
      eventful = Eventful::API.new ENV["EVENTFUL_API_KEY"]
      @result = eventful.call 'events/search',
            :category => get_categories,
            :location => get_location,
            :within => 10,
            :date => date,
            :image_sizes => 'perspectivecrop290by250',
            :sort_order => 'popularity',
            :include => 'categories',
            :page_size => 10
      @events = @result['events']['event']
    rescue
      @events = false
      end
  end 

  def make_map(events) 
    if events != false
    @hash = Gmaps4rails.build_markers(events) do |event, marker|
      marker.lat event['latitude']
      marker.lng event['longitude']
      marker.title event['title']
      marker.infowindow "<h6><a style=padding: 1.25em; href=#{event['url']}>Event Link</a><br>Title: #{event['title']}<br>Venue: #{event['venue_name']}</h6>"
    end 
  end
  end

  def default_eventful(date)
    default_city = CITY
    default_categories = CATEGORIES
    get_eventful(default_city, default_categories, date)
  end

  def user_eventful(date)
    latlong = "#{current_user.latitude},#{current_user.longitude}"
    categories = current_user.categories.collect { |category| category.cat_id }.join(',')
    get_eventful(latlong, categories, date)
  end

  def get_categories
    current_user ? current_user.categories.collect { |category| category.cat_id }.join(',') : CATEGORIES
  end  

  def get_location
    if session[:current_location]
      session[:current_location]
    else
      current_user ? "#{current_user.latitude},#{current_user.longitude}" : CITY
    end  
  end  

end