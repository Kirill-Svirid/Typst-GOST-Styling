#import "@preview/t4t:0.4.3"
#let document-type-list = ("normative", "developed")

#let document-base = state("document-base", (:))

#let document-mentions = state("document-mentions", (:))

#let is-document-valid(item) = {
  if type(item) != dictionary { return false }
  if not "type" in item.keys() { return false }
  if not "name" in item.keys() { return false }
  if not "title" in item.keys() { return false }
  if "year" in item.keys() {
    if type(item.at("year")) != int { return false }
  }
  return true
}
#let document-compose-sort-key(item) = { }

#let document-read-definition(item) = {
  let document = (:)
  document.insert("type", item.at("type", default: ""))
  document.insert("name", item.at("name", default: ""))
  document.insert("year", item.at("year", default: ""))
  document.insert("title", item.at("title", default: ""))
  return document
}

#let document-append-defs(..paths) = {
  let docs-def
  let docs = (:)
  for path in paths.pos() {
    docs-def = (yaml(path))
    for (k, v) in docs-def {
      if not is-document-valid(v) { continue }
      docs.insert(k, document-read-definition(v))
    }
  }
  document-base.update(s => {
    s = t4t.get.dict-merge(s, docs)
    return s
  })
}

#let document-ref(name) = context {
  let headings = query(heading.where(level: 2).or(heading.where(level: 1)).before(here()))
  headings = headings.filter(it => it.numbering != none)
  assert(
    headings.len() > 0,
    message: "Ссылка на документ не может быть использована без нумерованных заголовков уровня 1 или 2",
  )

  let header-parent = (headings.last())
  document-mentions.update(s => {
    let headers-mentioned = s.at(name, default: ())
    assert(type(headers-mentioned) == array, message: "Ссылки должны быть в виде массива локаций")
    if header-parent not in headers-mentioned {
      headers-mentioned.push(header-parent)
    }
    // headers-mentioned = headers-mentioned.dedup()
    s.insert(name, headers-mentioned)
    return s
  })
  {
    let v = document-base.final().at(name, default: none)
    if v != none { v = v.name }
    text(fill: eastern, v)
  }
}



#let document-get-mentioned() = {
  context document-mentions.final()
}
