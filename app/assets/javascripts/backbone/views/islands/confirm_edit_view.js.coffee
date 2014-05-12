MangroveValidation.Views.Islands ||= {}

# This view is used to confirm the users intent to edit an entire island,
# rather than a specific area. It does this by zooming to the island extent,
# then rendering a dialog box with confirm or reject.
# Upon either selection, the relevant callbacks are fired, and the bounds 
# are reset to their previous position
class MangroveValidation.Views.Islands.ConfirmEditView extends Backbone.View

  events:
    "click .continue-btn"  : "confirm"
    "click .cancel-btn"    : "reject"

  initialize: (options, confirmed, reject)=>
    if options.display_type is 'modal'
      @template = JST["backbone/templates/islands/confirm_edit"]
    else
      @template = JST["backbone/templates/islands/confirm_attributes_edit"]
      @className = 'alert'
      @id = 'confirm-edit-dialog'

    @confirm_callback = confirmed
    @confirm_callback ||= () ->
    @reject_callback = reject
    @reject_callback ||= () ->

  confirm: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @confirm_callback()
    @close()

  reject: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @reject_callback()
    @close()

  render: () =>
    $(@el).html(@template())
    return this
