#import "src/tools/pageframe.typ": page-frame-sequence, document-data
#import "src/tools/numbering.typ": heading-numbering-ru, enum-numbering
#import "src/tools/table-tools.typ": table-multi-page
#import "src/style.typ": *
#import "src/tools/outlines.typ": outline-break-by-enum
#import "src/tools/enums.typ": *
#import "src/tools/referencing.typ": *
#show: style-ver-1.with()


#show: enable-referenceable-enums.with()
#set page(background: page-frame-sequence())

#show outline.entry: outline-break-by-enum.with(0)
#let test-state = state("test", ())

// #let data = append-document-defs("/bibliography/references dev.yml", "/bibliography/references nor.yml")
// #let data=yaml("bibliography/references dev.yml")
#document-append-defs("/bibliography/references dev.yml", "/bibliography/references nor.yml")
// #toml("/bibliography/references dev.toml")
// #pagebreak()
#document-append-defs("/bibliography/references test.yml")

// State of context is: #context document-base.final()
// #data
#outline()
= Введение
Элемент<el>
#context link(query(label("el")).at(0).location(), [Ссылка])
// #link(<el>,[Link])
#show: enum-set-heading-numbering

= Feature
Простой текст со ссылкой на документ #document-ref("gost_r_iso_9001")

== Требования к обеспечению безопасности при выполнении работ

+ На всех этапах работ должно быть #document-ref("gost_r_8_563_2009") обеспечено соблюдение норм и правил, регламентирующих безопасность в области использования атомной энергии с учётом конструктивных и физических особенностей РУ и АЭС.

+ Эксперименты на стендах должны проводиться в соответствии с правилами ядерной и технической безопасности.#document-ref("gost_r_8_563_2009")

== Требования по обеспечению государственной тайны при выполнении НИР и ОКР

#set enum(numbering: wrapped-enum-numbering("1.a"), full: true)

+ #enum-label[reaf] Разработка ТВС должна выполняться с учётом обеспечения технологичности конструкций составных частей, обеспеченности сырьём и исходными материалами, а также с максимально возможным уровнем унификации.

+ Изготовление и сборка элементов а.з. должна проводиться в соответствии с СТО 95 12076.#document-ref("gost_r_8_563_2009") #document-ref("gost_r_15_012")

#show: enum-drop-heading-numbering

= Feature

#show: enum-set-heading-numbering
+ Технология изготовления, правила и методы приёмки и контроля ТВС должны обеспечивать:

// #show:enum-drop-heading-numbering

#set enum(numbering: "a.1")
+ сохранение герметичности в течение назначенного срока службы и назначенного срока хранения твэлов в составе ТВС.

#show: enum-set-heading-numbering
+ Порядок контроля должен быть определён на этапе разработки ТП.

+ На готовом изделии должны контролироваться параметры, указанные в 4.6.8.

+ Требования к составным частям и комплектующим деталям ТВС, к их приёмке и входному контролю устанавливает разработчик ТВС.

+ Оценка соответствия ТВС должна осуществляться в форме испытаний, контроля и приёмки согласно требованиям НП-071. Результаты оценки соответствия в форме приёмки должны оформляться заключением о приёмке в порядке, установленном ГОСТ Р 50.06.01.

Дополнение

= Feature

This is a simple template for testing.

Here's a simple equation:

#let doc = context document-base.final().at("gost_r_8_563_2009")


// #document-get-repr("gost_r_8_563_2009")

= Заключение

#document-display-group(inset: (top: 2mm, bottom: 2mm))
// #document-get-mentioned()
