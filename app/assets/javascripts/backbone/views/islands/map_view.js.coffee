MangroveValidation.Views.Islands ||= {}

CARTO_CSS_COLORS =
  unselected_color: '#00FFFF'
  selected_color: '#FFFF00'
  unselected_validated_color: '#00FF00'
  selected_validated_color: '#00FF00'

# = Map View
# Creates and manages the map and showing of layers
class MangroveValidation.Views.Islands.MapView extends Backbone.View
  template: JST["backbone/templates/islands/map"]

  initialize: (island) ->
    @island = island

    @map = new L.Map('map_canvas', window.VALIDATION.mapOptions)

    baseLayers =
      "Satellite": new L.BingLayer(window.VALIDATION.mapOptions.apiKey, {type: 'Aerial'})
      "Road": new L.BingLayer(window.VALIDATION.mapOptions.apiKey, {type: 'Road'})

    tileLayers =
      "All Islands": @buildIslandOverlay()

    @map.addLayer(baseLayers["Satellite"])
    @map.addLayer(tileLayers["All Islands"])

    L.control.layers(baseLayers, tileLayers).addTo @map

    # Bus binding
    @bindTo(MangroveValidation.bus, "zoomToBounds", @zoomToBounds)
    @bindTo(MangroveValidation.bus, "map:getCurrentBounds", @getCurrentBounds)
    @bindTo(MangroveValidation.bus, "toggleMapLayers", @toggleMapLayers)
    @bindTo(MangroveValidation.bus, "addToMap", @addToMap)
    @bindTo(MangroveValidation.bus, "layersChanged", @redrawLayers)

    # Bind to island events
    @island.on('change', @render)

    #google.maps.event.addListener @map, 'click', @handleMapClick

    @render()

  # Adds cartodb layer of all islands in subtle colour
  buildIslandOverlay: ->
    currentlyShownIslandId = @island.get('id')

    css = @cartoCSSGenerator(window.CARTODB_TABLE)

    # Add island highlighting
    if currentlyShownIslandId?
      css += @islandCartoCSSGenerator(window.CARTODB_TABLE, currentlyShownIslandId)

    query = "SELECT cartodb_id, the_geom_webmercator, status, id_gid FROM #{window.CARTODB_TABLE} WHERE status IS NOT NULL"
    tileUrl = "http://carbon-tool.cartodb.com/tiles/#{window.CARTODB_TABLE}/{z}/{x}/{y}.png?sql=#{query}&style=#{encodeURIComponent(css)}"

    return L.tileLayer(tileUrl)

  islandCartoCSSGenerator: (table, islandId) ->
      """
        ##{table} [id_gid = #{islandId}] {
          line-color: #{CARTO_CSS_COLORS.selected_color};polygon-fill:#{CARTO_CSS_COLORS.selected_color}; polygon-opacity:0.4
        }

        ##{table} [id_gid = #{islandId}][status='validated'] {
          line-color: #{CARTO_CSS_COLORS.selected_validated_color};polygon-fill: #{CARTO_CSS_COLORS.selected_validated_color};
        }
      """

  cartoCSSGenerator: (table) ->
    """
      ##{table} {
        polygon-fill:#{CARTO_CSS_COLORS.unselected_color};line-color:#{CARTO_CSS_COLORS.unselected_color};polygon-opacity:0.1;line-width:1;line-opacity:0.7;
      }

      ##{table} [status = 'validated'] {
        line-color: #{CARTO_CSS_COLORS.unselected_validated_color};polygon-fill: #{CARTO_CSS_COLORS.unselected_validated_color};
      }

      ##{table} [zoom <= 7] {
        line-width:2
      }

      ##{table} [zoom <= 4] {
        line-width:3
      }
    """

  handleMapClick: (event) =>
    if window.VALIDATION.currentAction == null
      @navigateToIslandAtPoint(event.latLng)
    else
      if @map.getZoom() >= window.VALIDATION.minEditZoom
        MangroveValidation.bus.trigger('mapClickAt', event.latLng)
      else
        alert("You can't edit geometry this far out, please zoom in")

  # Asks cartobd for any islands at the given point
  # and navigates to the island show path if one is found
  navigateToIslandAtPoint: (point) ->
    query = "SELECT id_gid FROM #{window.CARTODB_TABLE}
      WHERE ST_Intersects(the_geom, ST_GeomFromText('point(#{point.lng()} #{point.lat()})', 4326))
      LIMIT 1"

    $.ajax
      url: "#{window.CARTODB_API_ADDRESS}?q=#{query}"
      dataType: 'json'
      success: (data) ->
        if data.rows.length > 0
          # If we find a island, redirect to it
          window.router.navigate("#{data.rows[0].id_gid}", true)
        else
          # If no island, redirect to root '/'
          window.router.navigate("/", true)

  render: =>
    this

  addToMap: (object) =>
    object.setMap(@map)

  zoomToBounds: (bounds) =>
    @map.fitBounds(bounds)

  # passes the current map bounds to the callback
  getCurrentBounds: (callback) =>
    callback(@map.getBounds())

  # show or hide map overlays
  toggleMapLayers: (enable) =>
    @showLayers = enable
    @render()

  # Redraw the layers
  redrawLayers: () =>
    # Remove existing layers and set to null to force redraws
    if @allIslandsLayer?
      @allIslandsLayer.unbindAll()
      @allIslandsLayer = null

    @render()

