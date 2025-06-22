#import "@preview/t4t:0.4.3"
#let document-type-list = ("legislation", "reference")
#let document-base = state("document-base", (:))
#let document-mentions = state("document-mentions", (:))
#let document-backlinks = state("document-backlinks", (:))

#let _is-document-valid(item) = {
  if type(item) != dictionary { return false }
  if not "type" in item.keys() { return false }
  if not "name" in item.keys() { return false }
  if not "title" in item.keys() { return false }
  if "date" in item.keys() {
    if type(item.at("date")) != int { return false }
  }
  return true
}

#let _document-type-sort-prefix(key) = {
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


#let _document-read-definition(lbl, item) = {
  let document = (:)
  document.insert("label", lbl)
  document.insert("title", item.at("title", default: ""))
  document.insert("name", item.at("name", default: none))
  document.insert("organization", item.at("organization", default: none))
  assert(type(item.at("name")) == str, message: "Тип поля имя должен быть")

  assert(
    type(item.at("date")) in (int, datetime),
    message: "Дата должна или целым числом или выражением типа (datetime)",
  )
  assert(
    item.at("type") in document-type-list,
    message: "Неподдерживаемый тип документа. Поддерживаемые типы:" + repr(document-type-list),
  )
  document.insert("type", item.at("type"))
  document.insert("date", item.at("date", default: none))

  return document
}

#let document-append-defs(..paths) = {
  let docs-def
  let docs = (:)
  for path in paths.pos() {
    path = lower(path)
    if path.ends-with("yaml") or path.ends-with("yml") { docs-def = yaml(path) } else if path.ends-with("toml") {
      docs-def = toml(path)
    } else {
      panic("Объявлен неподдерживаемый тип файла. Поддерживаемые форматы: [YAML, TOML, JSON]")
    }

    for (k, v) in docs-def {
      if not _is-document-valid(v) { continue }
      docs.insert(k, _document-read-definition(k, v))
    }
  }
  document-base.update(s => {
    s = t4t.get.dict-merge(s, docs)
    return s
  })
}

// Предназначена для определения схемы представления документа
#let document-get-repr(document) = {
  let lbl = document.at("label")
  let type = document.at("type")
  let title = document.at("title")
  let name = document.at("name")
  let date = document.at("date")
  let organization = document.at("organization", default: none)

  let document-label = label("_link_" + lbl)
  [#metadata("")#document-label] + if organization != none [#{ organization }. ] + [#name] + [\-#date #title]

  document-backlinks.update(s => {
    assert(
      label not in s.keys(),
      message: "Функция не может быть вызвана дважды для одного документа",
    )
    s.insert(lbl, document-label)
    return s
  })
}

// Предназначена для определения схемы сортировки документа
#let document-get-sort-key(document-name) = {
  let item = document-base.final().at(document-name, default: none)
  if item == none { panic("Документ не обнаружен:" + document-name) }
  let type = item.at("type")
  let name = item.at("name")
  let prefix = _document-type-sort-prefix(name)
  return prefix + name
}

// Предназначена для объявления документа по тексту
#let document-ref(document-name, repr-function: none, year-last-two: false) = context {
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
  if v != none { document-inline = v.name }

  if backlink != none { link(backlink, [ #document-inline]) } else { [#document-inline] }
}

#let document-get-mentioned() = {
  context document-mentions.final()
}

#let header-legislation = (
  [Обозначение, наименование документа, на который дана ссылка],
  [Номер раздела, подраздела, приложения документа, в котором дана ссылка],
)
#let header-developed = (
  [Наименование организации, обозначение документа, наименование изделия, вид и инвентарный номер документа, на который дана ссылка],
  [Номер раздела, подраздела, приложения документа, в котором дана ссылка],
)


// Позволяет получить массив данных для отображения в финальной таблице ссылок
#let document-get-display-array(document-type, sort-by-type) = context {
  let mentions = document-mentions.final()
  let base = document-base.final()

  let label-array = mentions.keys()
  let header-array = mentions.values()
  let sort-array = mentions.keys().map(document-get-sort-key)

  for (i, v) in header-array.enumerate() {
    header-array.at(i) = v
      .map(h => link(
        h.location(),
        [#numbering(h.numbering, ..counter(heading).at(h.location()))],
      ))
      .join([, ])
  }

  let table-data = label-array.zip(header-array, sort-array)
  table-data = table-data.filter(it => { base.at(it.at(0)).at("type") == document-type })
  if sort-by-type {
    table-data = table-data.sorted(key: it => it.at(2))
  }
}


#let document-display-group(document-type: "legislation", header: header-legislation, ..table-args) = context {
  assert(
    type(header) == array and header.len() == 2,
    message: "Заголовок таблицы должен быть массивом с двумя элементами.",
  )
  let mentions = document-mentions.final()
  let base = document-base.final()

  let label-array = mentions.keys()
  let header-array = mentions.values()
  let sort-array = mentions.keys().map(document-get-sort-key)

  for (i, v) in header-array.enumerate() {
    header-array.at(i) = v.map(h => link(
      h.location(),
      [#numbering(h.numbering, ..counter(heading).at(h.location()))],
    ))
  }

  let table-data = label-array.zip(header-array, sort-array)
  table-data = table-data.filter(it => { base.at(it.at(0)).at("type") == document-type })
  table-data = table-data.sorted(key: it => it.at(2))

  show table.cell.where(y: 0): it => {
    set text(size: 12pt, hyphenate: false)
    set par(justify: false)
    it
  }

  table(
    inset: (top: 2mm, bottom: 2mm, rest: 0.5mm),
    columns: (13.0cm, 1fr),
    align: (x, y) => {
      if y == 0 { center + horizon } else if y > 0 and x == 0 { left + top } else { center + horizon }
    },
    row-gutter: (0.5mm, auto),
    table.header(..header),
    ..table-args,
    ..for (item, link, sort) in table-data {
      (
        [#document-get-repr(base.at(item))],
        [#link.join([, ])],
      )
    }
  )
}



