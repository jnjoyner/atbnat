#!/usr/bin/ruby
class Page
  require Dir.pwd + '/site_specs'
  include Site_specs
  def initialize p # Stands for the name of the page (a symbol if coming from code, a string if coming from CGI parameters)
    @p = p.to_sym # IN CASE the argument is in string form from CGI parameter
    @page_name = p.to_s
    @prop = Page_list[@p]
    @title = SITE_NAME  + ': ' + TAGLINE + ' :: ' + @page_name.capitalize unless @title = @prop[:t]
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
    <meta http-equiv="content-type" content="text/html; charset=#{ CHARSET }">
    <meta name="description" content="#{ @description }">
    <meta name="keywords" content="#{ @keywords }">
    <link rel = "stylesheet" type = "text/css" href = "css/#{STYLESHEET}">
    <title>#{ @title }</title>
    END_OF_HEAD
    ERB.new( head_content ).result(binding)
  end
  def navigation( navigation_menu, columns )
    rows = ( navigation_menu.length / columns ).to_i + 1
    row_count = 1
    navigation_html = %|<ul class="navigation">|
    navigation_menu.each_with_index do |menu_item, counter|
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
  def content( filename = nil )
    if filename
      fqfn = './content/'  + filename.to_s + '.html'
      if ! File.exist? fqfn
        `touch #{fqfn}` # create a blank file if no file exists
      end
      ERB.new( File.read( fqfn ) ).result(binding)
    else
      raise 'File name argument was not passed to "content" method, or was nil'
    end
  end
  def write_to_disk
    fqfn = '../' + @page_name + '.html'
    File.open(fqfn, 'w') do |fh|
      #html_output = ERB.new( @page_template_to_use ).result(binding)
      #puts( html_output )
      #fh.write( html_output )
      fh.write( ERB.new( @page_template_to_use ).result(binding) )
      File.chmod( 0604, fqfn )
    end
  end
end

begin
  `clear`
  require 'erb'
  Site_specs::Page_list.each_key do |page_name|
    Page.new( page_name ).write_to_disk
  end
  `clear`
rescue Exception => e
  puts e.message << "\n" << e.backtrace.first
end

