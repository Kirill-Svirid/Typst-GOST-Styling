#import "@preview/t4t:0.4.3"
#import "@local/oxifmt:1.0.0"

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


#let _document-read-definition(lbl, entity) = {
  let doc = (:)
  doc.insert("label", lbl)
  doc.insert("type", entity.at("type", default: none))
  doc.insert("name", entity.at("name", default: none))
  doc.insert("title", entity.at("title", default: none))
  doc.insert("organization", entity.at("organization", default: none))

  assert(
    (doc.at("title"), doc.at("name"), doc.at("title")).all(it => type(it) == str),
    message: "Поля (title,name,title) должны иметь тип str",
  )

  assert(
    entity.at("type") in document-type-list,
    message: "Неподдерживаемый тип документа. Поддерживаемые типы:" + repr(document-type-list),
  )
  let date = entity.at("date", default: none)
  assert(
    type(date) in (int, datetime, none),
    message: "Дата должна или целым числом или выражением типа (datetime)",
  )
  if type(date) == int {
    if date > 0 and date < 50 { date += 2000 } else if date >= 50 and date < 100 { date += 1900 }
  }
  assert(date > 1800, message: "Дата для документа не может быть менее 1800")


  doc.insert("date", entity.at("date", default: none))

  return doc
}

#let document-append-defs(..paths) = {
  let docs-def
  let docs = (:)
  for path in paths.pos() {
    path = lower(path)
    if path.ends-with("yaml") or path.ends-with("yml") { docs-def = yaml(path) } else if path.ends-with("toml") {
      docs-def = toml(path)
    } else if path.ends-with("json") { docs-def = json(path) } else {
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

  assert(
    type(document-name) in (str, content),
    message: "Поле (document-name) должно быть строкой или контентом",
  )

  let header-parent = (headings.last())
  document-mentions.update(s => {
    let headers-mentioned = s.at(document-name, default: ())
    assert(type(headers-mentioned) == array, message: "Ссылки должны быть в виде массива локаций")
    if header-parent not in headers-mentioned { headers-mentioned.push(header-parent) }
    s.insert(document-name, headers-mentioned)
    return s
  })

  let backlink-item = document-backlinks.final().at(document-name, default: none)

  let document-inline

  let v = document-base.final().at(document-name, default: none)
  if v != none { document-inline = v.name }

  if backlink-item != none { link(backlink-item, [ #document-inline]) } else { [#document-inline] }
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
#let document-get-as-array(document-type, sort-by-type: true) = {
  let mentions = document-mentions.final()
  assert(
    mentions.len() > 0,
    message: "Таблица не может быть сформирована без ссылок на документы в тексте",
  )

  let label-array = mentions.keys()
  let header-array = mentions.values()
  let sort-array = mentions.keys().map(document-get-sort-key)
  let item-array = label-array.map(it => document-base.final().at(it))

  for (i, v) in header-array.enumerate() {
    header-array.at(i) = v
      .map(h => link(
        h.location(),
        [#numbering(h.numbering, ..counter(heading).at(h.location()))],
      ))
      .join([, ])
  }

  let table-data = label-array.zip(header-array, sort-array, item-array)
  table-data = table-data.filter(it => { it.at(3).at("type") == document-type })
  if sort-by-type { table-data = table-data.sorted(key: it => it.at(2)) }
  return table-data
}


#let document-table-place(document-type: "legislation", header: header-legislation, ..table-args) = context {
  show table.cell.where(y: 0): it => {
    set text(size: 12pt, hyphenate: false)
    set par(justify: false)
    it
  }

  let table-data = document-get-as-array(document-type)

  table(
    columns: (13.0cm, 1fr),
    inset: (top: 2mm, bottom: 2mm),
    align: (x, y) => {
      if y == 0 { center + horizon } else if y > 0 and x == 0 { left + top } else { center + horizon }
    },
    table.header(..header),
    ..table-args,
    ..for (lbl, link, sort, item) in table-data {
      (
        [#document-get-repr(item)],
        [#link],
      )
    }
  )
}
