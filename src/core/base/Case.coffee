toComponent = require './toComponent'
TransformComponent = require './TransformComponent'
{funcString, newLine, intersect} = require '../../util'
{renew} = require '../../flow'

module.exports = class Case extends TransformComponent
  constructor: (test, map, else_, options={}) ->
    if typeof test != 'function'
      if map.hasOwnPoperty(test) then return toComponent(map[key])
      else return toComponent(else_)

    if options.convertToIf
      for key, value of map
        else_ = new  If((->test()==key), value, else_)
      return else_

    super(options)

    families = for _, value of map then value.family
    families.push else_.family
    @family = family = intersect(families)
    family[@dcid] = true

    if !test.invalidate then test = renew(test)
    test.onInvalidate(@invalidate.bind(@))

    for key, value of map
      map[key] = toComponent(value) #comp =
      #comp.container = comp.holder = @
    else_ = toComponent(else_)
    #else_.container = else_.holder = @

    @getContentComponent = -> map[test()] or else_

    @clone = (options) ->
      cloneMap = Object.create(null)
      for key, value of map
        cloneMap[key] = value.clone()
      (new Case(test, cloneMap, else_clone(), options or @options)).copyLifeCallback(@)

    @toString = (indent=0, noNewLine) ->
      s = newLine(indent, noNewLine)+'<Case '+funcString(test)+'>'
      for key, comp of map
        s += newLine(key+': '+comp.toString(indent+2, true), indent+2)
      s += else_.toString(indent+2)+newLine('</Case>', indent)

    this
