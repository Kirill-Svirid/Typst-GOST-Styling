#import "utils.typ": *
// Source:https://github.com/typst/typst/issues/779#issuecomment-2702268234
/// Used to allow reference with the `enum-label` function
#let enu-label-mark = metadata("enumeration_label")

#let enum-label(label) = {
  if type(label) == content {
    assert(label.has("text"), message: "enum-label requires text content")
    label = label.text
  }
  [#enu-label-mark#std.label(label)]
}

// Purpose: track enumeration items
#let enum-counter-name = "enum-counter"
// State for tracking the numbering format of enumeration items
#let enum-numbering-state = state("enum-numbering", none)

#let wrapped-enum-numbering(numbering) = {
  let enum-numbering = (..it) => {
    enum-numbering-state.update(x => numbering)
    counter(enum-counter-name).update(it.pos())
    std.numbering(numbering, ..it)
  }
  enum-numbering
}

#show ref: it => {
  let el = it.element
  if el != none and el.func() == metadata and el == enu-label-mark {
    let supp = it.supplement
    if supp == auto { supp = "Item" }
    // get the counter value in the correct format according to location
    let loc = el.location()
    let ref-counter = context numbering(state("enum-numbering").at(loc), ..counter(enum-counter-name).at(loc))
    if is-empty(supp) {
      link(el.location(), ref-counter)
    } else {
      link(el.location(), box([#supp~#ref-counter]))
    }
  } else {
    it
  }
}
