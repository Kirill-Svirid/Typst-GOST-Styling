#let left_offset = 20mm
#let main_offset = 5mm
#let main_thickness = 0.5mm
#let secondary_thickness = 0.2mm
#let color-default = black

#let content-empty = label => not (label.has("children") and label.children.len() > 0 or label.has("text"))


#let document-data = (
  "Обозначение": text(size: 16pt, [Обозначение документа]),
  "Наименование": [],
  "Организация": text(size: 16pt, [Организация]),
  "Разраб": [],
  "Пров.": [],
  "Н. контр.": [],
  "Утв.": [],
  "Пров": [],
  "Версия": [],
)

#let tbl_inventory() = {
  set text(size: 12pt)
  table(
    columns: (25mm, 35mm, 25mm, 25mm, 35mm),
    rows: (5mm, 7mm),
    inset: 0mm,
    align: center + horizon,
    stroke: main_thickness + color-default,
    [Инв. № подл.], [Подп. и дата], [Взам. инв. №], [Инв. №дубл.], [Подп. и дата],
    [], [], [], [], [],
  )
}

// Секция таблицы для указания пользователей
#let tbl-section-0(document-data: document-data) = {
  assert("Разраб" in document-data.keys(), message: "Key error")
  assert("Пров." in document-data.keys(), message: "Key error")
  assert("Н. контр." in document-data.keys(), message: "Key error")
  assert("Утв." in document-data.keys(), message: "Key error")
  set text(size: 11pt)
  table(
    columns: (17mm, 23mm, 15mm, 10mm),
    stroke: secondary_thickness,
    align: center + horizon,
    inset: 0mm,
    rows: 5mm,
    table.vline(x: 1, stroke: main_thickness),
    table.vline(x: 2, stroke: main_thickness),
    table.vline(x: 3, stroke: main_thickness),
    [Разраб], document-data.at("Разраб"), [], [],
    [Пров.], document-data.at("Пров."), [], [],
    [], [], [], [],
    [Н. контр.], document-data.at("Н. контр."), [], [],
    [Утв.], document-data.at("Утв."), [], [],
  )
}

// Секция таблицы для указания обозначения и версии
#let tbl-section-1(document-data: document-data, page-current: []) = {
  let schema = (120mm,)

  assert("Обозначение" in document-data.keys(), message: "Key error")
  assert("Версия" in document-data.keys(), message: "Key error")

  let content = (document-data.at("Обозначение"),)

  if not content-empty(document-data.at("Версия")) {
    schema.at(0) = schema.at(0) - 10mm
    schema.push(10mm)
    content.push(
      table(
        rows: (5mm, 10mm),
        columns: 10mm,
        inset: 0mm,
        [Вер.],
        version
      ),
    )
  }
  if not content-empty(page-current) {
    schema.at(0) = schema.at(0) - 10mm
    schema.push(10mm)
    content.push(
      table(
        rows: (5mm, 10mm),
        inset: 0mm,
        columns: 10mm,
        [Лист],
        page-current
      ),
    )
  }
  grid(
    align: center + horizon,
    stroke: main_thickness,
    columns: schema,
    inset: 0mm,
    rows: 15mm,
    ..content
  )
}

// Секция для организации и номеров страниц
#let tbl-section-2(document-data: document-data, page-current: [], page-total: []) = {
  assert("Организация" in document-data.keys(), message: "Key error")
  set text(size: 12pt)
  table(
    align: center + horizon,
    stroke: main_thickness,
    columns: (5mm, 5mm, 5mm, 15mm, 20mm),
    rows: (5mm, 5mm, 15mm),
    table.cell(colspan: 3, [Лит.]), [Лист], [Листов],
    [], [], [], page-current, page-total,
    table.cell(colspan: 5, document-data.at("Организация"))
  )
}

// Секция для названия
#let tbl-section-3(document-data: document-data) = {
  set text(size: 12pt)
  table(
    stroke: main_thickness,
    columns: 70mm,
    rows: 25mm,
    [],
  )
}

// Секция для изменений
#let tbl-section-4() = {
  set text(size: 12pt)
  table(
    columns: (7mm, 10mm, 23mm, 15mm, 10mm),
    stroke: main_thickness + color-default,
    rows: 5mm,
    inset: 0mm,
    align: center + horizon,
    [], [], [], [], [],
    table.hline(stroke: secondary_thickness),
    [], [], [], [], [],
    scale(x: 85%, [Изм]), [Лист], [№ докум.], [Подп.], [Дата],
  )
}

// Секция для указания применений
#let tbl-section-5(document-data: document-data) = {
  set text(size: 11pt)
  table(
    columns: (60mm, 60mm),
    rows: (5mm, 7mm),
    stroke: main_thickness + color-default,
    inset: 0mm,
    align: center + horizon,
    [Справ. №], [Перв. примен.],
    [], [],
  )
}

#let first-page-frame(title) = {
  context {
    let width = 185mm
    let height = 40mm
  }
  let main-grid = grid(
    columns: (65mm, 70mm, 50mm),
    rows: (15mm, 25mm),
    stroke: main_thickness,
    grid.cell(rowspan: 2),
    {
      set text(size: 5mm)
      grid.cell(colspan: 2, table(columns: 120mm, rows: 15mm, align: center + horizon, title))
    }, [],
    grid.cell(),
  )
}

#let page-outer-frame() = {
  context {
    let width = page.width
    let height = page.height
    place(
      top + left,
      curve(
        fill: none,
        stroke: main_thickness + color-default,
        curve.move((0mm, 0mm)),
        curve.line((width - left_offset - main_offset, 0mm)),
        curve.line((width - left_offset - main_offset, height - main_offset * 2)),
        curve.line((0mm, height - main_offset * 2)),
        curve.close(),
      ),
      dx: left_offset,
      dy: main_offset,
    )
  }
}

#let first-page-bar-grid(document-data: document-data) = {
  context {
    let width = 185mm
    let height = 40mm
    place(
      bottom + right,
      grid(
        columns: (65mm, 70mm, 50mm),
        stroke: main_thickness + color-default,
        rows: (3 * 5mm, 5 * 5mm),
        grid.cell(rowspan: 1, tbl-section-4()),
        grid.cell(colspan: 2, tbl-section-1(document-data: document-data)),
        tbl-section-0(document-data: document-data),
        tbl-section-3(document-data: document-data),
        tbl-section-2(
          document-data: document-data,
          page-current: [ #here().page() ],
          page-total: [#counter(page).final().at(0)],
        )
      ),
      dx: -main_offset,
      dy: -main_offset,
    )
  }
}

#let second-page-bar-grid(document-data: document-data) = {
  context {
    let width = 185mm
    let height = 15mm
    place(
      bottom + right,
      grid(
        columns: (65mm, 120mm),
        stroke: main_thickness + color-default,
        rows: 15mm,
        tbl-section-4(),
        tbl-section-1(
          document-data: document-data,
          page-current: [ #here().page() ],
        ),
      ),
      dx: -main_offset,
      dy: -main_offset,
    )
  }
}

#let main-page-frame(document-data: document-data) = {
  context {
    let page-counter = counter("page")
    page-counter.step()
    let width = page.width
    let height = page.height
    // first-page-bar-grid(str(page-counter.get().first()))
    // second-page-bar-grid(document-data:document-data)
    first-page-bar-grid(document-data: document-data)
    place(
      bottom,
      rotate(-90deg, tbl_inventory(), reflow: true),
      dx: left_offset - 12mm,
      dy: -main_offset,
    )
    place(
      bottom,
      rotate(-90deg, tbl-section-5(document-data: document-data), reflow: true),
      dx: left_offset - 12mm,
      dy: -main_offset - 287mm + 120mm,
    )
  }
  page-outer-frame()
}

#let second-page-frame(document-data: document-data) = {
  context {
    let width = page.width
    let height = page.height
    second-page-bar-grid(document-data: document-data)
    place(
      bottom,
      rotate(-90deg, tbl_inventory(), reflow: true),
      dx: left_offset - 12mm,
      dy: -main_offset,
    )
  }
  page-outer-frame()
}

#let page-frame-sequence(document-data: document-data) = context {
  let (count,) = counter("page").get()
  if count == 0 {
    main-page-frame(document-data: document-data)
  } else {
    second-page-frame(document-data: document-data)
  }
}

#let page-footer-sequence() = context {
  let (count,) = counter("page").get()
  [#count]
  if count == 0 {
    h(5cm)
    [text]
  }
}

#let page-layout-sequence(body) = {
  context {
    let (count,) = counter("page").get()
    set page(margin: (left:3cm),footer: [ #count ])

    body
  }
}



// #let page-frame-sequence(document-data: document-data, body) =context  {
//     let page-counter = counter("page")
//     page-counter.step()
//     if page-counter.get().first() == 0 {
//       set page(
//         background: main-page-frame(document-data: document-data),
//       )
//       // main-page-frame(document-data: document-data)
//     } else {
//       set page(
//         background:second-page-frame(document-data: document-data),
//       )
//       // second-page-frame(document-data: document-data)
//     }
//   body
// }


#let title-page-frame() = { }
