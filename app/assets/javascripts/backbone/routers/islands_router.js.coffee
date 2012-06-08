class MangroveValidation.Routers.IslandsRouter extends Backbone.Router
  initialize: (options) ->
    @islands = new MangroveValidation.Collections.IslandsCollection()
    @island = new MangroveValidation.Models.Island()

    @sidePanelManager = new MangroveValidation.ViewManager("#right-main")

    # Base layout
    @baseLayout()

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    @view = new MangroveValidation.Views.Islands.IndexView(islands: @islands)
    $("#islands").html(@view.render().el)

    # Tooltips
    $('#map_menu .show-tooltip').tooltip({placement: 'bottom'})

    $('#landingModal').modal()

  show: (id) ->
    #@islands.getAndResetById(id)
    @island.set({id: id})
    @island.fetch()
    
    @sidePanelManager.showView(new MangroveValidation.Views.Islands.IslandView(model: @island))

  baseLayout: ->
    # Search box
    $("#search").typeahead
      source: (typeahead, query) =>
        @islands.search query, (collection, response) ->
          typeahead.process(response)
      items: 4
      property: 'name'
      onselect: (obj) ->
        window.router.navigate("#{obj.id}", true)
    $("#search").focus (e) =>
      $(e.target).val('')
      @islands.search(null)
    # Prevent search form submission
    $(".navbar-search").submit (e) ->
      e.preventDefault()

    @mapView = new MangroveValidation.Views.Islands.MapView(@island)
    @searchResultsView = new MangroveValidation.Views.Islands.SearchResultsView(@islands)
