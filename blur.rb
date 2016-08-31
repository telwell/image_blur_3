class Image


  def initialize(data)
    @pixels = []
    construct_pixels(data)
    @height = @pixels.count - 1
    @width  = @pixels[0].count - 1
  end
  
  
  # Convenience method for outputing the image as a nested array of 1's and 0's
  def show
    buffer = []
    @pixels.each do |row|
      temp = []
      row.each do |pixel|
        temp << pixel.value
      end
      buffer << temp
    end
    pp buffer
  end
  
  
  def blur(dist)
    @pixels.each_with_index do |pixel_row, y|
      pixel_row.each_with_index do |pixel, x|
        if pixel.one? && !pixel.changed
          # Ripple is the mama function here. See comments below.
          ripple(x, y, dist)
        end
      end
    end
  end
  
private
  
  
  def ripple(x, y, dist)
    # There are four directions: up, down, left, right. We simply need a way to
    # define each direction. For instance, the first object in directions below 
    # is the object for 'up'. As you can see, the x coordinate stays the same
    # while the y value increases (subtraction is going 'up' in this example).
    # The four below are simply ways to define a direction in the coordinate plane.
    directions = [
      {x: x, y: Proc.new { |i| y - (i + 1) }},
      {x: x, y: Proc.new { |i| y + (i + 1) }},
      {x: Proc.new { |i| x + (i + 1) }, y: y},
      {x: Proc.new { |i| x - (i + 1) }, y: y}
    ]
    directions.each do |direction|
      dist.times do |i|
        
        # Now that we've defined each of our directions we need to build our coordinates
        # out of them. Each time we iterate through i we change the fluctuating value of
        # our direction (the value that is a Proc). The other value remains stagnant.
        temp_y = (direction[:y].class == Proc ? direction[:y].call(i) : direction[:y])
        temp_x = (direction[:x].class == Proc ? direction[:x].call(i) : direction[:x])
        
        # If we're outside of our image then we can break in this direction.
        break if temp_y < 0 || temp_y > @height || temp_x < 0 || temp_x > @width
        
        # This is for the 'pointy' end of the ripple.
        if i == dist - 1
          @pixels[temp_y][temp_x].toggle! unless @pixels[temp_y][temp_x].one?
        else
          @pixels[temp_y][temp_x].toggle! unless @pixels[temp_y][temp_x].one?
          
          # If the y value is the fluctuating value then we want to toggle the pixels 
          # to the current pixel's left and right. Otherwise, toggle the pixels above
          # and below.
          if (direction[:y].class == Proc)
            @pixels[temp_y][temp_x - 1].toggle! unless (temp_x - 1) < 0 || @pixels[temp_y][temp_x - 1].one?
            @pixels[temp_y][temp_x + 1].toggle! unless (temp_x + 1) > @width || @pixels[temp_y][temp_x + 1].one?
          else 
            @pixels[temp_y - 1][temp_x].toggle! unless (temp_y - 1) < 0 || @pixels[temp_y - 1][temp_x].one?
            @pixels[temp_y + 1][temp_x].toggle! unless (temp_y + 1) > @height || @pixels[temp_y + 1][temp_x].one?
          end
        end
      end
    end
  end
  
  
  # Build our pixels 2D array
  def construct_pixels(data)
    data.each do |array|
      temp = []
      array.each do |pixel_value|
        temp << Pixel.new(pixel_value)
      end
      @pixels << temp
    end
  end
  
end


class Pixel
  attr_reader :value
  attr_reader :changed


  def initialize(value)
    @value = value # 0 or 1
    @changed = false
  end


  def toggle!
    if !@changed
      # Toggle @value
      @value = (@value == 0 ? 1 : 0)
      @changed = true
    end
  end


  def one?
    @value == 1
  end
  
end
