module Site_specs
  # Uses make_oop_mobi
  DOMAIN = 'alesgrilldeli'
  TLD = 'com'
  TITLE = %{ Las Ale’s Mexican Grill Deli - AlesGrillDeli.com}
  DESCRIPTION = %{Taqueria y Deli in Atascadero, California}
  JAVASCRIPT_SOURCES = []
  
  def body( page_name ) # page_name is a symbol
    main(
      content( page_name )
      ) +
    footer
  end
  Page_list = {
    home: { },
  }
end
