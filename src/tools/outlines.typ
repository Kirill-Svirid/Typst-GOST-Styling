#let header-counter = counter("header-all")

#show heading: it => {
  header-counter.step()
  it
}

// Break outline feed by specified break-points (array or int).
// Before usage counter header-all must be applied to headers.
#let outline-break-by-enum(break-points, entry) = {
  let loc = entry.element.location()
  let c = counter("header-all").at(loc).at(0)
  if type(break-points) == int { break-points = (break-points,) }
  if break-points.contains(c) { pagebreak(weak: true) + entry } else { entry }
}


#let outline-break-by-header-body(break-heading, entry) = {
  let loc = entry.element.location()
  assert(type(break-heading) == label, message: "Type of argument must be label")
  let show-break = { entry.element.body == query(break-heading).at(0).body }
  if show-break { pagebreak() + entry } else { entry }
}
