{expect, iit, idescribe, nit, ndescribe} = require('./helper')

{bindings
isComponent
Component, TransformComponent, Tag, Text,
txt, list, List, func, if_, case_, func, each
accordionGroup, accordion
a, p, span, text, div
bind, pour, see} = dc

{$a, $b, _a, _b} = bindings({a: 1, b: 2})

describe 'list, each', ->
  describe 'List', ->
    it 'all of item in list should be  component', ->
      comp = list([1, 2])
      expect(!!isComponent(comp.children[0])).to.equal(true)

    it 'should create list component', ->
      comp =  list([span(['adf'])])
      comp.mount()
      expect(comp.node.tagName).to.equal 'SPAN'

    it 'component list should have length', ->
      lst = list([1, 2])
      expect(lst.children.length).to.equal 2

    it 'list can be constructructed  from mulitple argumnents', ->
      lst = list(1, 2)
      expect(lst.children.length).to.equal 2

    it 'should create list', ->
      lst = list(1, 2)
      lst.mount()
      expect(lst.node[0].textContent).to.equal '1'
      expect(lst.node[1].textContent).to.equal '2'

    it 'should create list with attrs', ->
      x = 2
      comp = list({class:'main', fakeProp:-> x}, 1, txt(->x))
      comp.mount()
      expect(comp.node.tagName).to.equal 'DIV'
      expect(comp.node.childNodes[0].textContent).to.equal '1'
      expect(comp.node.childNodes[1].textContent).to.equal '2'
      x = 3
      comp.update()
      expect(comp.node.fakeProp).to.equal 3
      expect(comp.node.childNodes[1].textContent).to.equal '3', 'textContent update'

    it 'list(txt(->12))', ->
      comp = list(txt(->12))
      comp.mount()
      expect(comp.node.textContent).to.equal '12'

    it 'list setChildren after mounting', ->
      comp = new List([txt(1)])
      comp.mount()
      expect(comp.node[0].textContent).to.equal '1'
      expect(->comp.setChildren(1, t2=txt(2))).to.throw()

    it 'list setChildren: similar to splitter', ->
      comp = new List([txt(1), t3=txt(3)])
      comp.setChildren(1, t2=txt(2), t3)
      comp.mount()
      expect(comp.node[0].textContent).to.equal '1'
      expect(comp.node[1].textContent).to.equal '2'
      expect(comp.node[2].textContent).to.equal '3'

    it 'list(p(txt(->12))) ', ->
      comp = list(p(txt(->12)))
      comp.mount()
      comp.update()
      expect(comp.node.innerHTML).to.equal '12'

    it 'list(p(->12)) ', ->
      comp = list(p(->12))
      comp.mount()
      comp.update()
      expect(comp.node.innerHTML).to.equal '12'

  describe 'Each', ->
    it  'should create each component', ->
      comp = each(lst = ['each', 'simple'], (item, i) -> p(item))
      comp.mount()
      expect(comp.node).to.be.instanceof Array
      expect(comp.node[0]).to.be.instanceof Element

    it 'should mount and render each component',  ->
      document.getElementById('demo').innerHTML = ''
      comp = each(lst=['each', 'simple'], (item, i) -> p(item))
      comp.mount("#demo")
      expect(comp.node[0].innerHTML).to.equal 'each'
      expect(comp.node[1].innerHTML).to.equal 'simple'
      lst.setItem 0,  3
      comp.update()
      expect(comp.node[0].innerHTML).to.equal '3', 'update node 0'
      lst.setItem 1, 4
      comp.update()
      expect(comp.node[1].innerHTML).to.equal '4', 'update node 1'
      lst.setItem 2, 5
      comp.update()
      expect(comp.node[2].innerHTML).to.equal '5', 'update list[2] = 5'
      lst.setLength 0
      comp.update()
      expect(comp.listComponent.children.length).to.equal 0, 'comp.listComponent.children.length = 0'
      #  comp.node is Text(''), comp.node.length is the TextNode.length ,which is also 0 :)
      expect(comp.node.length).to.equal 0, 'lst.length == TextNode.length == 0'

    it 'should process immutable template in each component', ->
      document.getElementById('demo').innerHTML = ''
      comp = each(lst = [{text:'a'}, {text:'b'}], ((item, i) -> p(txt(bind item, 'text'))), {itemTemplateImmutable:true})
      comp.mount("#demo")
      expect(comp.node[0].textContent).to.equal 'a'
      expect(comp.node[1].textContent).to.equal 'b'
      lst[0].text = 'c'
      comp.update()
      expect(comp.node[0].textContent).to.equal 'c', 'update c'
      lst[1].text = 'd'
      comp.update()
      expect(comp.node[1].textContent).to.equal 'd', 'update d'
      lst.setItem 2, {text: 'e'}
      comp.update()
      expect(comp.node[2].textContent).to.equal 'e'
      lst.setLength 0
      comp.update()
      expect(comp.node.length).to.equal 0

    it 'should process itemTemplateImmutable each component ', ->
      comp = each(lst = ['a', 'b'], ((item, i, list) -> p(txt(-> list[i]))), {itemTemplateImmutable:true})
      comp.mount()
      lst.setItem 0, 'c'
      comp.update()
      expect(comp.node[0].textContent).to.equal 'c'

    it 'should process tag with each', ->
      x = 1
      text1 = null
      comp = new Tag('div', {}, [each1=each([1], pour (item) -> text1 = txt(x))])
      comp.create()
      expect(comp.node.innerHTML).to.equal '1'
      x = 2
      comp.update()
      expect(text1.node.textContent).to.equal('2', 'update, 2')
      expect(each1.node[0].textContent).to.equal('2')
      expect(comp.node.innerHTML).to.equal '2'

    it  'should create and update renew function as list of Each', ->
      x = 1
      comp = each((-> [x]), (item) -> txt(item))
      comp.mount()
      expect(comp.node[0].textContent).to.equal '1'
      x = 2
      comp.update()
      expect(comp.node[0].textContent).to.equal('2', 'update 2')

    it  'should create and update deeper embedded each', ->
      x = 1
      comp =  div({}, span1=new Tag('span', {}, [each1=each((-> [x]), (item) -> txt(item))]))
      comp.mount()
      expect(each1.listComponent.parentNode).to.equal(span1.node)
      expect(each1.node[0].textContent).to.equal '1'
      x = 2
      comp.update()
      expect(each1.listComponent.parentNode).to.equal(span1.node)
      expect(each1.node[0].textContent).to.equal('2')
      expect(comp.node.innerHTML).to.equal '<span>2</span>'

    it  'should create and update embedded each in 3 layer', ->
      x = see 1
      comp =  div({}, div({}, span1=new Tag('span', {}, [each1=each([1], (item) -> txt(x))])))
      comp.mount()
      expect(each1.listComponent.parentNode).to.equal(span1.node)
      expect(each1.node[0].textContent).to.equal '1'
      x 2
      comp.update()
      expect(each1.listComponent.parentNode).to.equal(span1.node)
      expect(each1.node[0].textContent).to.equal('2')
      expect(comp.node.innerHTML).to.equal '<div><span>2</span></div>'

    it  'should create and update embedded each in 3  layer', ->
      x = 1
      comp =  div({}, div({}, span1=new Tag('span', {}, [each1=each((-> [x]), (item) -> txt(item))])))
      comp.mount()
      expect(each1.listComponent.parentNode).to.equal(span1.node)
      expect(each1.node[0].textContent).to.equal '1'
      x = 2
      comp.update()
      expect(each1.listComponent.parentNode).to.equal(span1.node)
      expect(each1.node[0].textContent).to.equal('2')
      expect(comp.node.innerHTML).to.equal '<div><span>2</span></div>'

    it  'should process each under each', ->
      x = 1
      each2 = null
      comp = div({}, each1=each([1], -> each2=each((-> [x]), (item) -> item)))
      comp.mount()
      expect(each1.listComponent.parentNode).to.equal(comp.node)
      expect(each1.node[0][0].textContent).to.equal '1'
      expect(each2.node[0].textContent).to.equal '1'
#      x = 2
#      comp.update()
#      expect(each1.listComponent.parentNode).to.equal(comp.node)
#      expect(each2.node[0].textContent).to.equal('2')
#      expect(comp.node.innerHTML).to.equal '2'

    it  'should mount and update each', ->
      comp = new Tag('span', {}, [each([1], (item) -> txt(1))])
      comp.mount()
      expect(comp.node.innerHTML).to.equal '1'
      comp.update()
      expect(comp.node.innerHTML).to.equal '1'

    it  'should update each with component as the item of list 1', ->
      comp = each([txt(1)], (item) -> item)
      comp.mount()
      expect(comp.node[0].textContent).to.equal s='1'
      comp.update()
      expect(comp.node[0].textContent).to.equal '1'

    it  'should update each with component as the item of list 2', ->
      comp = div(each([txt(1)], (item) -> item))
      comp.mount()
      expect(comp.node.innerHTML).to.equal s='1'
      comp.update()
      expect(comp.node.innerHTML).to.equal '1'

    it  'should update each with component as the item of list 3', ->
      comp = div(div(each([txt(1)], (item) -> item)))
      comp.mount()
      expect(comp.node.innerHTML).to.equal s='<div>1</div>'
      comp.update()
      expect(comp.node.innerHTML).to.equal '<div>1</div>'
