{View, $} = require 'space-pen'
{TextEditorElement, CompositeDisposable} = require 'atom'
Grim = require 'grim'

# Public: Represents the entire visual pane in Atom.
#
# The TextEditorView manages the {TextEditor}, which manages the file buffers.
# `TextEditorView` is intentionally sparse. Most of the things you'll want
# to do are on {TextEditor}.
#
# ## Examples
#
# Requiring in packages
#
# ```coffee
# {TextEditorView} = require 'atom'
#
# miniEditorView = new TextEditorView(mini: true)
# ```
#
# Iterating over the open editor views
#
# ```coffee
# for editorView in atom.workspaceView.getEditorViews()
#   console.log(editorView.getModel().getPath())
# ```
#
# Subscribing to every current and future editor
#
# ```coffee
# atom.workspace.eachEditorView (editorView) ->
#   console.log(editorView.getModel().getPath())
# ```
module.exports =
class TextEditorView extends View
  # The constructor for setting up an `TextEditorView` instance.
  #
  # * `modelOrParams` Either an {TextEditor}, or an object with one property, `mini`.
  #    If `mini` is `true`, a "miniature" `TextEditor` is constructed.
  #    Typically, this is ideal for scenarios where you need an Atom editor,
  #    but without all the chrome, like scrollbars, gutter, _e.t.c._.
  #
  constructor: (modelOrParams, props) ->
    # Handle direct construction with an editor or params
    unless modelOrParams instanceof HTMLElement
      if modelOrParams.constructor isnt Object
        model = modelOrParams
      else
        {editor, mini, placeholderText, attributes} = modelOrParams
        model = editor
        attributes ?= {}
        attributes.mini = true if mini
        attributes['placeholder-text'] = placeholderText if placeholderText?

      element = new TextEditorElement
      element.lineOverdrawMargin = props?.lineOverdrawMargin
      element.setAttribute(name, value) for name, value of attributes if attributes?

      if model?
        element.setModel(model)
      else
        element.getModel()

      return element.__spacePenView

    # Handle construction with an element
    @element = modelOrParams

    unless @useLegacyAttachHooks
      @element.onDidAttach => @attached()
      @element.onDidDetach => @detached()

    super

  attached: ->
    return if @isAttached
    @isAttached = true
    @trigger 'editor:attached', [this]

  detached: ->
    if @getModel()?.isDestroyed()
      @isAttached = false
      @trigger 'editor:detached', [this]

  setModel: (@model) ->
    @editor = @model

    @scrollView = @find('.scroll-view')
    @underlayer = @find('.highlights').addClass('underlayer')
    @overlayer = @find('.lines').addClass('overlayer')
    @hiddenInput = @.find('.hidden-input')

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'editor.showLineNumbers', =>
      @gutter = @find('.gutter')

      @gutter.removeClassFromAllLines = (klass) =>
        Grim.deprecate('Use decorations instead: http://blog.atom.io/2014/07/24/decorations.html')
        @gutter.find('.line-number').removeClass(klass)

      @gutter.getLineNumberElement = (bufferRow) =>
        Grim.deprecate('Use decorations instead: http://blog.atom.io/2014/07/24/decorations.html')
        @gutter.find("[data-buffer-row='#{bufferRow}']")

      @gutter.addClassToLine = (bufferRow, klass) =>
        Grim.deprecate('Use decorations instead: http://blog.atom.io/2014/07/24/decorations.html')
        lines = @gutter.find("[data-buffer-row='#{bufferRow}']")
        lines.addClass(klass)
        lines.length > 0

    @subscriptions.add @model.onDidDestroy => @subscriptions.dispose()

  # Public: Get the underlying editor model for this view.
  #
  # Returns an {TextEditor}
  getModel: -> @model

  getEditor: -> @model

  on: (eventName) ->
    switch eventName
      when 'cursor:moved'
        Grim.deprecate('Use TextEditor::onDidChangeCursorPosition instead')
      when 'editor:attached'
        Grim.deprecate('Use TextEditor::onDidAddTextEditor instead')
      when 'editor:detached'
        Grim.deprecate('Use TextEditor::onDidDestroy instead')
      when 'editor:will-be-removed'
        Grim.deprecate('Use TextEditor::onDidDestroy instead')
      when 'selection:changed'
        Grim.deprecate('Use TextEditor::onDidChangeSelectionRange instead')
    super

  Object.defineProperty @::, 'lineHeight', get: -> @model.getLineHeightInPixels()
  Object.defineProperty @::, 'charWidth', get: -> @model.getDefaultCharWidth()
  Object.defineProperty @::, 'firstRenderedScreenRow', get: -> @component.getRenderedRowRange()[0]
  Object.defineProperty @::, 'lastRenderedScreenRow', get: -> @component.getRenderedRowRange()[1]
  Object.defineProperty @::, 'active', get: -> @is(@getPaneView()?.activeView)
  Object.defineProperty @::, 'isFocused', get: -> @component?.state.focused
  Object.defineProperty @::, 'mini', get: -> @component?.props.mini
  Object.defineProperty @::, 'component', get: -> @element?.component

  remove: (selector, keepData) ->
    @model.destroy() unless keepData
    super

  scrollTop: (scrollTop) ->
    if scrollTop?
      @model.setScrollTop(scrollTop)
    else
      @model.getScrollTop()

  scrollLeft: (scrollLeft) ->
    if scrollLeft?
      @model.setScrollLeft(scrollLeft)
    else
      @model.getScrollLeft()

  scrollToBottom: ->
    Grim.deprecate 'Use TextEditor::scrollToBottom instead. You can get the editor via editorView.getModel()'
    @model.setScrollBottom(Infinity)

  scrollToScreenPosition: (screenPosition, options) ->
    Grim.deprecate 'Use TextEditor::scrollToScreenPosition instead. You can get the editor via editorView.getModel()'
    @model.scrollToScreenPosition(screenPosition, options)

  scrollToBufferPosition: (bufferPosition, options) ->
    Grim.deprecate 'Use TextEditor::scrollToBufferPosition instead. You can get the editor via editorView.getModel()'
    @model.scrollToBufferPosition(bufferPosition, options)

  scrollToCursorPosition: ->
    Grim.deprecate 'Use TextEditor::scrollToCursorPosition instead. You can get the editor via editorView.getModel()'
    @model.scrollToCursorPosition()

  pixelPositionForBufferPosition: (bufferPosition) ->
    Grim.deprecate 'Use TextEditor::pixelPositionForBufferPosition instead. You can get the editor via editorView.getModel()'
    @model.pixelPositionForBufferPosition(bufferPosition)

  pixelPositionForScreenPosition: (screenPosition) ->
    Grim.deprecate 'Use TextEditor::pixelPositionForScreenPosition instead. You can get the editor via editorView.getModel()'
    @model.pixelPositionForScreenPosition(screenPosition)

  appendToLinesView: (view) ->
    view.css('position', 'absolute')
    view.css('z-index', 1)
    @find('.lines').prepend(view)

  splitLeft: ->
    Grim.deprecate """
      Use Pane::splitLeft instead.
      To duplicate this editor into the split use:
      editorView.getPaneView().getModel().splitLeft(copyActiveItem: true)
    """
    pane = @getPaneView()
    pane?.splitLeft(pane?.copyActiveItem()).activeView

  splitRight: ->
    Grim.deprecate """
      Use Pane::splitRight instead.
      To duplicate this editor into the split use:
      editorView.getPaneView().getModel().splitRight(copyActiveItem: true)
    """
    pane = @getPaneView()
    pane?.splitRight(pane?.copyActiveItem()).activeView

  splitUp: ->
    Grim.deprecate """
      Use Pane::splitUp instead.
      To duplicate this editor into the split use:
      editorView.getPaneView().getModel().splitUp(copyActiveItem: true)
    """
    pane = @getPaneView()
    pane?.splitUp(pane?.copyActiveItem()).activeView

  splitDown: ->
    Grim.deprecate """
      Use Pane::splitDown instead.
      To duplicate this editor into the split use:
      editorView.getPaneView().getModel().splitDown(copyActiveItem: true)
    """
    pane = @getPaneView()
    pane?.splitDown(pane?.copyActiveItem()).activeView

  # Public: Get this {TextEditorView}'s {PaneView}.
  #
  # Returns a {PaneView}
  getPaneView: ->
    @parent('.item-views').parents('atom-pane').view()
  getPane: ->
    Grim.deprecate 'Use TextEditorView::getPaneView() instead'
    @getPaneView()

  show: ->
    super
    @component?.checkForVisibilityChange()

  hide: ->
    super
    @component?.checkForVisibilityChange()

  pageDown: ->
    Grim.deprecate('Use editorView.getModel().pageDown()')
    @model.pageDown()

  pageUp: ->
    Grim.deprecate('Use editorView.getModel().pageUp()')
    @model.pageUp()

  getFirstVisibleScreenRow: ->
    Grim.deprecate 'Use TextEditor::getFirstVisibleScreenRow instead. You can get the editor via editorView.getModel()'
    @model.getFirstVisibleScreenRow()

  getLastVisibleScreenRow: ->
    Grim.deprecate 'Use TextEditor::getLastVisibleScreenRow instead. You can get the editor via editorView.getModel()'
    @model.getLastVisibleScreenRow()

  getFontFamily: ->
    Grim.deprecate 'This is going away. Use atom.config.get("editor.fontFamily") instead'
    @component?.getFontFamily()

  setFontFamily: (fontFamily) ->
    Grim.deprecate 'This is going away. Use atom.config.set("editor.fontFamily", "my-font") instead'
    @component?.setFontFamily(fontFamily)

  getFontSize: ->
    Grim.deprecate 'This is going away. Use atom.config.get("editor.fontSize") instead'
    @component?.getFontSize()

  setFontSize: (fontSize) ->
    Grim.deprecate 'This is going away. Use atom.config.set("editor.fontSize", 12) instead'
    @component?.setFontSize(fontSize)

  setLineHeight: (lineHeight) ->
    Grim.deprecate 'This is going away. Use atom.config.set("editor.lineHeight", 1.5) instead'
    @component.setLineHeight(lineHeight)

  setWidthInChars: (widthInChars) ->
    @component.getDOMNode().style.width = (@model.getDefaultCharWidth() * widthInChars) + 'px'

  setShowIndentGuide: (showIndentGuide) ->
    Grim.deprecate 'This is going away. Use atom.config.set("editor.showIndentGuide", true|false) instead'
    @component.setShowIndentGuide(showIndentGuide)

  setSoftWrap: (softWrapped) ->
    Grim.deprecate 'Use TextEditor::setSoftWrapped instead. You can get the editor via editorView.getModel()'
    @model.setSoftWrapped(softWrapped)

  setShowInvisibles: (showInvisibles) ->
    Grim.deprecate 'This is going away. Use atom.config.set("editor.showInvisibles", true|false) instead'
    @component.setShowInvisibles(showInvisibles)

  getText: ->
    @model.getText()

  setText: (text) ->
    @model.setText(text)

  insertText: (text) ->
    @model.insertText(text)

  isInputEnabled: ->
    @component.isInputEnabled()

  setInputEnabled: (inputEnabled) ->
    @component.setInputEnabled(inputEnabled)

  requestDisplayUpdate: ->
    Grim.deprecate('Please remove from your code. ::requestDisplayUpdate no longer does anything')

  updateDisplay: ->
    Grim.deprecate('Please remove from your code. ::updateDisplay no longer does anything')

  resetDisplay: ->
    Grim.deprecate('Please remove from your code. ::resetDisplay no longer does anything')

  redraw: ->
    Grim.deprecate('Please remove from your code. ::redraw no longer does anything')

  setPlaceholderText: (placeholderText) ->
    Grim.deprecate('Use TextEditor::setPlaceholderText instead. eg. editorView.getModel().setPlaceholderText(text)')
    @model.setPlaceholderText(placeholderText)

  lineElementForScreenRow: (screenRow) ->
    $(@component.lineNodeForScreenRow(screenRow))
