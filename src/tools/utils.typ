#let is-empty(value) = {
  let empty-values = (
    array: (),
    dictionary: (:),
    str: "",
    content: [],
  )
  let t = repr(type(value))
  if t in empty-values {
    return value == empty-values.at(t)
  } else {
    return value == none
  }
}


#let to-string(content) = {
  if content.has("text") {
    if type(content.text) == str {
      content.text
    } else {
      to-string(content.text)
    }
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// Convert string quotes into new, when the input is string.
// For now Typst doesn't convert them, if they are provided as is
#let string-convert-quote-marks(s,l-side:"«",r-side:"»") = {
  let m = s.matches(regex("^?(?:[\s]?)([\"\'])[^\s\"\']"))
  for v in m {
    s = s.replace(v.text, v.text.replace(v.captures.first(), l-side))
  }
  s = s.replace(regex("[\"\']"), r-side)
  return s
}
