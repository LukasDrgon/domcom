toComponent = require './toComponent'
BaseComponent = require './BaseComponent'
Text = require './Text'
{checkContainer, newLine} = require '../../util'
{checkConflictOffspring, insertNode} = require '../../dom-util'

module.exports = exports = class List extends BaseComponent
  constructor: (children, options) ->
    if !children.length then return new Text('')
    @children = children
    options = options or {}
    super(options)
    @family = family = Object.create(null)
    family[@dcid] = true
    for child, i in children
      children[i] = child = toComponent(child)
      checkConflictOffspring(family, child)
      child.setRefContainer(@)
    @isList = true
    @length = children.length
    return

  clone: (options) -> (new List((for child in @children then child.clone()), options or @options)).copyLifeCallback(@)

  setChildren: (startIndex, newChildren...) ->
    {children, created} = @
    if created
      throw new Error 'do not allow set children after the Dom of List Component was created'
    created and @invalidate()
    i = startIndex
    for child in newChildren
      child = toComponent child
      child.setRefContainer(@)
      child.holder = @
      child.parentNode = @parentNode
      child.listIndex = i
      children[i] = child
      child
      i++
    @length = children.length
    return @

  createDom: ->
    @resetContainerHookUpdater()
    children = @children
    listLength = children.length
    if !listLength
      @lastLeaf = @firstLeaf = @emptyPlaceHolder = none = new Text('')
      @node = [ none.createDom()]
      return
    @node = node = []
    for child, i in children
      child.listIndex = i
      child.parentNode = @parentNode
      node[i] = child.render(true)
    i = 0; lastIndex = listLength-1
    # do not need set firstNode and lastNode for List Component
    # we always use component.firstLeaf.firstNode and component.lastLeaf.LastNode
    @firstLeaf = children[0].firstLeaf
    @lastLeaf = children[lastIndex].lastLeaf
    while i<lastIndex
      children[i].lastLeaf.nextLeaf = children[i+1].firstLeaf
      i++
    while i
      children[i].firstLeaf.prevLeaf = children[i-1].lastLeaf
      i--
    node

  updateDom: (mounting) ->
    @resetContainerHookUpdater()
    @updateOffspring(mounting)
    @children.length = @length
    @node

  getNode: -> @node

  attachNode: (nextNode) ->
    @unmounted = false
    if !@parentNode then return
    container = @container
    if container and container.isList
      container.node[@listIndex] = @node
      if !container.created or container.detached then  return @node
    if @created and !@detached then return @node
    @detached = false
    insertNode(@parentNode, @node, nextNode)

  removeNode: ->
    if !@parentNode or @unmounted then return
    for child in @children
      child.baseComponent.removeNode()
    return

  insertChild: (index, child) ->
    if @created
      throw new Error 'do not allow set children after the Dom of List Component was created'
    children = @children
    child = toComponent(child, @, index)
    child.setRefContainer(container)
    children.splice(index, 0, child)
    @length++
    @

  removeChild: (index) ->
    if @created
      throw new Error 'do not allow set children after the Dom of List Component was created'
    @children.splice(index, 1)
    @

  setFirstLast: (removed, replaced) ->
    removedFirst = removed.firstLeaf
    if removedFirst==@firstLeaf
      newFirst = replaced and replaced.firstLeaf or removed.nextLeaf
      @firstLeaf = newFirst
      me = @; holder = @holder
      while me.listIndex
        if removedFirst!=holder.firstLeaf then break
        holder.firstLeaf = newFirst
        me = holder; holder = @holder
    removedLast = removed.lastLeaf
    if removedLast==@lastLeaf
      newLast = replaced and replaced.lastLeaf or removed.prevLeaf
      @lastLeaf = newLast
      me = @; holder = @holder
      while me.listIndex
        if removedLast==holder.lastLeaf then break
        holder.firstLeaf = newLast
        me = holder; holder = @holder
    return

  toString: (indent=0, noNewLine) ->
    s = newLine("<List>", indent, noNewLine)
    for child in @children
      s += child.toString(indent+2)
    s += newLine('</List>', indent)