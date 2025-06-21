#import "@preview/t4t:0.4.3"
#let document-type-list = ("normative", "developed")
#let document-base = state("document-base", (:))
#let document-mentions = state("document-mentions", (:))
#let document-backlinks = state("document-backlinks", (:))

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

#let document-type-sort-prefix(key) = {
  key = lower(key)
  let case = (
    (key.match(regex("^гост.*")), "000"),
    (key.match(regex("^нп.*")), "010"),
    (key.match(regex("^санпин.*")), "020"),
    (key.match(regex("^сп.*")), "025"),
    (key.match(regex("^ост.*")), "030"),
    (key.match(regex("^стк.*")), "040"),
    (key.match(regex("^сто.*")), "050"),
    (key.match(regex("^ту.*")), "060"),
    (true, "100"),
  )
  return case.find(it => it.at(0) != none).at(1)
}


#let document-read-definition(item) = {
  let document = (:)
  document.insert("title", item.at("title", default: ""))
  document.insert("name", item.at("name", default: ""))
  document.insert("year", item.at("year", default: 0))
  if item.at("type") not in document-type-list {
    document.insert("type", document-type-list.at(0))
  } else {
    document.insert("type", item.at("type", default: ""))
  }
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

// Предназначена для определения схемы представления документа
#let document-get-repr(document-name) = context {
  let item = document-base.final().at(document-name)
  let type = item.at("type")
  let title = item.at("title")
  let name = item.at("name")
  let year = item.at("year")
  let document-label = label("_link_" + document-name)
  [#name#document-label] + [\-#year #title]

  document-backlinks.update(s => {
    assert(
      document-name not in s.keys(),
      message: "Функция не может быть вызвана дважды для одного документа",
    )
    s.insert(document-name, document-label)
    return s
  })
}

// Предназначена для определения схемы сортировки документа
#let document-get-sort-key(document-name) = context {
  let item = document-base.final().at(document-name)
  let type = item.at("type")
  let name = item.at("name")
  let prefix = document-type-sort-prefix(name)
  return prefix + name
}

#let document-ref(document-name) = context {
  let headings = query(heading.where(level: 2).or(heading.where(level: 1)).before(here()))
  headings = headings.filter(it => it.numbering != none)
  assert(
    headings.len() > 0,
    message: "Ссылка на документ не может быть использована без нумерованных заголовков уровня 1 или 2",
  )

  if type(document-name) == content {
    std.assert(document-name.has("text"), message: "Name requires text content")
    document-name = document-name.text
  }

  let header-parent = (headings.last())
  document-mentions.update(s => {
    let headers-mentioned = s.at(document-name, default: ())
    assert(type(headers-mentioned) == array, message: "Ссылки должны быть в виде массива локаций")
    if header-parent not in headers-mentioned { headers-mentioned.push(header-parent) }
    s.insert(document-name, headers-mentioned)
    return s
  })

  let backlink = document-backlinks.final().at(document-name, default: none)

  let document-inline

  let v = document-base.final().at(document-name, default: none)
  if v != none {
    document-inline = v.name
  }

  if backlink != none { link(backlink, [ #document-inline]) } else {
    [#document-inline]
  }
}

#let document-get-mentioned() = {
  context document-mentions.final()
}

#let document-display-group(type: document-type-list.at(0), ..table-args) = context {
  let header-normative = (
    [Обозначение, наименование документа, на который дана ссылка],
    [Номер раздела, подраздела, приложения документа, в котором дана ссылка],
  )
  let header-developed = (
    [Наименование организации, обозначение документа, наименование изделия, вид и инвентарный номер документа, на который дана ссылка],
    [Номер раздела, подраздела, приложения документа, в котором дана ссылка],
  )

  let table-header = if type == "normative" { header-normative } else { header-developed }
  let mentions = document-mentions.final()
  let repr-array = mentions.keys()
  let header-array = mentions.values()
  let sort-array = mentions.keys().map(document-get-sort-key)
  let a
  for (i, v) in header-array.enumerate() {
    a = header-array.at(i)
    header-array.at(i) = v.map(h => link(
      h.location(),
      [#numbering(h.numbering, ..counter(heading).at(h.location()))],
    ))
  }

  show table.cell.where(y: 0): set text(size: 12pt, hyphenate: false)
  show table: set par(justify: false)

  table(
    inset: (top: 2mm, bottom: 2mm, rest: 0.5mm),
    columns: (13.0cm, 1fr, 1fr),
    align: (x, y) => {
      if y == 0 { center + horizon } else if y > 0 and x == 0 { left + top } else { center + horizon }
    },
    row-gutter: (0.5mm, auto),
    ..table-args,
    table.header(..table-header, [sort]),
    ..for (item, link, sort) in repr-array.zip(header-array, sort-array) {
      ([#document-get-repr(item)], [#link.join([, ])], [#sort])
    }
  )
}



