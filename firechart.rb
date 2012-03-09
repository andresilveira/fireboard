class FireChart
  
  GRAPH_FACTOR = 5.5 # because of chart size limited (yet)
  
  attr_accessor :project_name, :data, :options
  
  def initialize project_name, data, options = {}
    @current_scale = 1
    @project_name = project_name
    @data = data
    @options = options
  end
  
  def auto_scale 
    if self.data.max > 100
      @current_scale = (self.data.max / 100.0).ceil
    end
    return @current_scale
  end
  
  def print_scale
    %Q{
      <rect x="830" y="625" width="150" height="25" fill="white" />
      <text font-family="Verdana" font-size="15" fill="black" x="855" y="643">Escala: #{@current_scale}x</text>
    }
  end

  def generate_shape
    %Q{
      <rect x='0' y='0' width='980' height='650' fill='rgb(241,241,241)' style='stroke:rgb(241,241,241); stroke-width: 10'/>
      <rect x='50' y='50' width='930' height='550' fill='white' />
    }
  end
  
  def generate_grid_and_axis
     grid = "<!-- horizontals --> \n"
      11.times{ |n|
        grid <<
        %Q{ <text x="15" y="#{55+n*55}" font-family="Verdana" font-size="15" fill="black" >#{100 - n*10}</text>  
            <line x1='50' y1='#{50+n*55}' x2='980' y2='#{50+n*55}' style='stroke:rgb(241,241,241); stroke-width: 1'/> 
          }
      }

      grid << "<!-- verticals --> \n"
      31.times{ |n|
        grid << 
        %Q{ <text x="#{45 + 30 * n}" y="620" font-family="Verdana" font-size="15" fill="black" >#{n+1}</text> 
            <line x1='#{80 + 30 * n}' y1='600' x2='#{80 + 30 * n}' y2='50' style='stroke:rgb(241,241,241); stroke-width: 1'/>
        }
      }
      
      return grid
  end
  
  def put_project_title
    %Q{<text x="300" y="25" font-family="Verdana" font-size="20" fill="black" >#{self.project_name}</text>}
  end
  
  def generate_marks 
    marks = " "
    i = 0
    dia = 50
    while i < self.data.size
      marks += "<circle cx='#{dia}' cy='#{600 - self.data[i] * (GRAPH_FACTOR/@current_scale)}' r='4' fill='#2166AC' /> \n"
      i += 1
      dia += 30
    end
    return marks
  end
  
  def generate_data_line
    data_line = "<polyline style='stroke:#2166AC; stroke-width: 2' fill='none'
    points= ' "

    i = 0
    dia = 50

    while i < self.data.size
      data_line += "#{dia}, #{600 - self.data[i] * (GRAPH_FACTOR / @current_scale)} \n"
      i += 1
      dia += 30
    end

    data_line += "'/>"

    return data_line
  end
 
  def create_chart
    auto_scale 
    
    svg_string = %Q{<?xml version='1.0' encoding='UTF-8'?>
      <!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>
      <?xml-stylesheet href='brushmetal.css' type='text/css'?>
      <svg xmlns='http://www.w3.org/2000/svg' version='1.1'>
      <!-- Axis and Graph Shape -->
      #{generate_shape}
      #{put_project_title}
      #{generate_grid_and_axis}
      <!-- / Axis and Graph Shape -->
      #{generate_marks}
      <!-- / Marks -->
      <!-- Data_Line -->
      #{generate_data_line}
      #{print_scale}
      <!-- / Data_Line -->
      </svg>
    }
    
    if self.options[:path]
      File.open(self.options[:path],"w"){ |arq| 
        arq.write(svg_string)
      }
    else
      File.open("#{self.project_name}.svg","w"){ |arq| 
        arq.write(svg_string)
      }
    end
  end
end
