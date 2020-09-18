class Page
  require Dir.pwd + '/site_specs.rb'
  include Site_specs
  def initialize p # Stands for the name of the page (a symbol if coming from code, a string if coming from CGI parameters)
    @p = p.to_sym # IN CASE the argument is in string form from CGI parameter
    @page_name = p.to_s
    @prop = Page_list[@p]
    @title = SITE_NAME  + ': ' + SITE_EPITHET + ' :: ' + @page_name.capitalize unless @title = @prop[:t]
    @description = SITE_NAME + '::' + @page_name.capitalize unless @description = @prop[:d]
    @keywords = @prop[:k]
    @primary_navigation_menu = Primary_navigation unless @primary_navigation_menu = @prop[:pn]
    @secondary_navigation_menu = Secondary_navigation unless @secondary_navigation_menu = @prop[:sn]
    @page_template_to_use = Template_default unless @page_template_to_use = @prop[:T]
    @head = self.head
    #@page_image = self.page_image
  end
  def head
    head_content = <<-END_OF_HEAD
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <meta name="description" content="#{ @description }">
    <meta name="keywords" content="#{ @keywords }">
    <link rel = "stylesheet" type = "text/css" href = "css/#{STYLESHEET}">
    <title>#{ @title }</title>
    END_OF_HEAD
    ERB.new( head_content ).result(binding)
  end
  def navigation( navigation_menu, columns, convert_spaces=true )
    rows = ( navigation_menu.length / columns ).to_i + 1
    row_count = 1
    navigation_html = %|<ul class="navigation">|
    navigation_menu.each_with_index do |menu_item, counter|
      if Navigation_properties[menu_item]
        item_title = Navigation_properties[menu_item][0].to_s
        if convert_spaces
          item_title = item_title.gsub ' ', '&nbsp;'
        end
        if Navigation_properties[menu_item][1]
          href = Navigation_properties[menu_item][1]
        else
          href = menu_item.to_s + '.html'
        end
      else
        href = menu_item.to_s + '.html'
        item_title = menu_item.to_s.gsub( '_', '&nbsp;' ).capitalize
      end
      navigation_html << <<-END_OF_MENU_ITEM
      <li>
      <a class="#{menu_item.to_s}" href="#{href}">#{item_title}</a>
      </li>
      END_OF_MENU_ITEM
      if counter == navigation_menu.length
        break
      else
        row_count += 1
        if row_count == rows
          row_count = 0
          navigation_html << %|\n</ul>\n<ul class="navigation">\n|
        end
      end
    end
    navigation_html << '</ul>'
    navigation_html
  end
  def nav_array_to_ul ( which_nav_menu )
    navigation_html = %|<ul class="navigation">|
    which_nav_menu.each do |menu_item|
      if Navigation_properties[menu_item]
        item_title = Navigation_properties[menu_item][0].to_s.gsub ' ', '&nbsp;'
        if Navigation_properties[menu_item][1]
          href = Navigation_properties[menu_item][1]
        else
          href = menu_item.to_s + '.html'
        end 
      else
        href = menu_item.to_s + '.html'
        item_title = menu_item.to_s.gsub( '_', '&nbsp;' ).capitalize
      end 
      navigation_html << %{<li><a class="#{menu_item.to_s}" href="#{href}">#{item_title}</a></li>\n} # NOTE the \n
    end   
    navigation_html << '</ul>'
  end
  # BELOW IS DEPRECATED OCT 16 2013 !!!
  def nav_bar( navigation_menu, id="primary_navigation" )
    # THIS IS DEPRECATED OCT 16 2013 !!!
    navigation_html = %|<ul id="#{id}" class="navigation inline_list">|
    navigation_menu.each do |menu_item|
      if Navigation_properties[menu_item]
        item_title = Navigation_properties[menu_item][0].to_s.gsub ' ', '&nbsp;'
        if Navigation_properties[menu_item][1]
          href = Navigation_properties[menu_item][1]
        else
          href = menu_item.to_s + '.html'
        end 
      else
        href = menu_item.to_s + '.html'
        item_title = menu_item.to_s.gsub( '_', '&nbsp;' ).capitalize
      end 
      navigation_html << %{<li><a class="#{menu_item.to_s}" href="#{href}">#{item_title}</a></li>\n} # NOTE the \n
    end   
    navigation_html << '</ul>'
  end
              
  def page_image
    if Page_list[@p][:i]
    #if Properties[@p][:i]
      image_attributes = Page_images[ Page_list[@p][:i] ]
      <<-IMG_TAG
      <img
      src="#{image_attributes[:source]}"
      alt="#{image_attributes[:alt_title]}"
      title="#{image_attributes[:alt_title]}"
      >
      IMG_TAG
    end
  end
  def content( filename = nil )
    if filename
      fqfn = '../content/'  + filename.to_s + '.html'
      if ! File.exist? fqfn
        `touch #{fqfn}` # create a blank file if no file exists
      end
      ERB.new( File.read( fqfn ) ).result(binding)
    else
      raise 'File name argument was not passed to "content" method, or was nil'
    end
  end
  def galleriffic album_dir
    galleriffic_html = <<-END_OF_GALLERIFFIC_HEADER
      <div id="controls" class="controls"></div>
      <div id="thumbs">
        <ul class="thumbs noscript">
        END_OF_GALLERIFFIC_HEADER
        Dir.entries( '../public/img/' + album_dir ).each do |fn|
          if File.directory?( fn )
            next
          end
          galleriffic_html << <<-END_OF_PHOTO
          <li>
          <a class="thumb" name="optionalCustomIdentifier" href="img/#{album_dir + '/' + fn}" title="Altar Guild">
            <img src="img/#{album_dir + '/' + fn}" alt="#{fn}" >
          </a>
          <!-- <div class="caption">#{fn}</div> -->
          </li>
          END_OF_PHOTO
        end
        galleriffic_html << <<-END_OF_GALLERIFFIC_FOOTER
      </ul>
    </div>
    <div class="slideshow-container">
      <div id="loading" class="loader"></div>
      <div id="slideshow" class="slideshow"></div>
    </div>
    <!-- <div id="caption" class="caption-container"></div> -->
    END_OF_GALLERIFFIC_FOOTER
    galleriffic_html
  end
  def copyright
   (defined? COPYRIGHT) ? COPYRIGHT : SITE_NAME
  end
  def clearer
    '<p class="clearer">&copy;' + copyright() + '</p>'
  end
  def ul( simple_list, id_attribute=nil, class_attribute=nil )
    html = %{<ul id="#{id_attribute}" class="#{class_attribute}">\n}
    simple_list.split("\n").each do |item|
      html << '<li>' + item.to_s + '</li>' + "\n"
    end
    html << '</ul>'
  end
  def ol( type, simple_list )
    case type
    when :number
      html = '<ol>'
    when :upper
      html = '<ol type="A">'
    when :lower
      html = '<ol type="a">'
    end
    simple_list.split("\n").each do |item|
      html << '<li>' + item.to_s + '</li>' + "\n"
    end
    html << '</ol>'
  end

  def clean_string( string_to_process)
    cleaned_string = ''
    string_to_process.each_char do |char|
      cleaned_string << char if char.ascii_only? and char.ord.between?(32,126)
    end
    return cleaned_string
  end

  def make_one_page( list_of_topics, include_headings=false )
    output = ''
    list_of_topics.each do |topic, heading|
      if include_headings
        output << "<h2 class='" + topic.to_s + "'>\n" + heading + "\n</h2>\n"
      end
      output << "\n<div id='" + topic.to_s + "'>\n" + content( topic ) + "\n</div>\n"
    end
    return output
  end

# Below method in page.rb disabled -- see same method in individual project
  def parDISABLED( simple_list, id_attribute=nil, class_attribute=nil )
    html = %{<p id="#{id_attribute}" class="#{class_attribute}">\n}
    simple_list.split("\n").each do |item|
      html << item.to_s + '</p>' + "\n" + '<p>' + "\n"
    end
    html
  end

  def write_to_disk
    fqfn = '../public/' + @page_name + '.html'
    File.open(fqfn, 'w') do |fh|
      #html_output = ERB.new( @page_template_to_use ).result(binding)
      #puts( html_output )
      #fh.write( html_output )
      fh.write( ERB.new( @page_template_to_use ).result(binding) )
      File.chmod( 0604, fqfn )
    end
  end
end
