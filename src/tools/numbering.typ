#import "@preview/t4t:0.4.3": is-empty

#let get-numbering-alphabet-ru(number) = {
  let alphabet = (
    "а",
    "б",
    "в",
    "г",
    "д",
    "е",
    "ж",
    "и",
    "к",
    "л",
    "м",
    "н",
    "п",
    "р",
    "с",
    "т",
    "у",
    "ф",
    "х",
    "ц",
    "ч",
    "ш",
    "щ",
    "э",
    "ю",
    "я",
  )
  let result = ""
  while number > 0 {
    result = alphabet.at(calc.rem(number - 1, 28)) + result
    number = calc.floor(number / 28)
  }
  return result
}

// Purpose: track enumeration items
#let enum-counter-name = "enum-counter"
#let enum-numbering-state = state("enum-numbering", none)
#let enum-label-mark = metadata("enumeration_label")


#let enum-label(label) = {
  if type(label) == content {
    std.assert(label.has("text"), message: "enum-label requires text content")
    label = label.text
    [#enum-label-mark#std.label(label)]
  } else if type(label) == std.label {
    [#enum-label-mark#label]
  } else if type(label) == str {
    [#enum-label-mark#std.label(label)]
  } else {
    panic("Unexpected value")
  }
}




#let enable-referenceable-enums(doc) = {
  show ref: it => {
    let el = it.element
    if el != none and el.func() == metadata and el == enum-label-mark {
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
  doc
}

#let wrapped-enum-numbering(numbering) = {
  let enum-numbering = (..it) => {
    enum-numbering-state.update(x => numbering)
    counter(enum-counter-name).update(it.pos())
    std.numbering(numbering, ..it)
  }
  enum-numbering
}

#let _enum-heading-numbering(..nums) = {
  let headings = query(selector(heading).before(here()))
  let last = headings.at(-1)
  assert(
    last.numbering != none,
    message: "Нумерованных пунктов не может быть в заголовке без нумерации.\n Ошибка возникла в заголовке:"
      + repr(last.body),
  )
  counter(heading).step(level: last.level + nums.pos().len())
  context { counter(heading).display() }
}



#let _enum-numbering(..nums) = {
  nums = nums.pos()
  assert(nums.len() <= 2, message: "Уровень вложенности не должен превышать 2")
  let letter = get-numbering-alphabet-ru(nums.first())
  let rest = nums.slice(1).map(elem => str(elem))
  if rest.len() == 0 {
    return letter + ")"
  } else {
    return rest.last() + ")"
  }
}


#let heading-numbering-ru(..nums) = {
  nums = nums.pos()
  let letter = upper(get-numbering-alphabet-ru(nums.first()))
  let rest = nums.slice(1).map(elem => str(elem))
  if rest != none {
    return (letter, rest).flatten().join(".")
  }
  return letter
}


#let enum-heading-numbering(doc) = {
  set enum(
    numbering: wrapped-enum-numbering(_enum-heading-numbering),
    indent: 1.25cm,
    full: true,
  )
  doc
}

#let enum-list-numbering(doc) = {
  set enum(
    numbering: wrapped-enum-numbering(_enum-numbering),
    indent: 1.25cm,
    full: true,
  )
  doc
}
