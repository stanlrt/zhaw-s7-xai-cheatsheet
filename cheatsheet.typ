// Local, customizable fork of @preview/simple-cheatsheet:0.1.0
// Adds knobs for compactness: container inset, heading spacing,
// paragraph leading/spacing, list spacing/indent, plus the originals
// (font-size, margin, columns).

#let palette = (
  rgb(156, 92, 58),
  rgb(62, 107, 135),
  rgb(143, 31, 36),
  rgb(106, 76, 147),
  rgb(196, 152, 27),
  rgb(147, 76, 90),
  rgb(24, 82, 33)
)

#let get-color(location: location) = {
  let index = counter(heading).at(location).first() - 1
  return palette.at(calc.rem(index, palette.len()))
}

#let deep-merge(base, override) = {
  let result = (:)

  for (key, value) in base {
    result.insert(key, value)
  }

  for (key, value) in override {
    if type(value) == array and value.len() == 0 {
      continue
    }

    if key in base and type(value) == dictionary and type(base.at(key)) == dictionary {
      result.insert(key, deep-merge(base.at(key), value))
    } else {
      result.insert(key, value)
    }
  }

  result
}

#let corner = 2pt

// global default inset, set by cheatsheet() from layout.container-inset
#let _container-inset = state("cheatsheet-container-inset", (x: 1em, y: 1em))

// inset: pass `auto` to use the global default, or override per-block.
#let container(
  body,
  alignment: start,
  inset: auto,
) = context {
  let pad = if inset == auto { _container-inset.get() } else { inset }
  block(
    stroke: get-color(location: here()),
    radius: corner + 1pt,
    inset: pad,
  )[
    #align(alignment)[
      #body
    ]
  ]
}

#let cheatsheet(
  info: (
    title: "",
    authors: (),
  ),
  headers: (
    align: center,
    numbering: true,
  ),
  layout: (:),
  body
) = {

  let defaults = (
    font-size: 6pt,
    margin: (
      x: 10pt,
      y: 20pt,
    ),
    columns: (
      count: 4,
      gutter: 4pt,
    ),
    // --- new compactness knobs ---
    // gap between paragraphs/blocks inside text
    par-spacing: 0.65em,
    // line spacing within a paragraph
    leading: 0.65em,
    // spacing between list items
    list-spacing: 0.65em,
    // bullet-to-text indent for lists
    list-indent: 0pt,
    // vertical space above/below the colored level-1 heading bars
    heading-above: 6pt,
    heading-below: 6pt,
    // inner padding of #container[] blocks
    container-inset: (x: 1em, y: 1em),
  )
  let layout = deep-merge(defaults, layout)

  let authors_array = if not type(info.authors) == array {
    (info.authors,)
  } else {
    info.authors
  }

  set page(
    paper: "a4",
    flipped: true,
    margin: layout.margin,
    header: [
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        [
          #text(datetime.today().display("[month repr:long] [day], [year]"), weight: "bold")
        ],
        [
          #text(if info.title == "" { "Cheatsheet" } else { info.title + " Cheatsheet" }, weight: "bold")
        ],
        [
          #text(authors_array.join(", ", last: " & "), weight: "bold")
        ]
      )
      #v(2pt)
      #line(length: 100%, stroke: black)
    ],
    footer: context [
      #align(center)[
        #text(weight: "bold")[#counter(page).display("1 / 1", both: true)]
      ]
    ],
  )

  let get-numbered-heading(it, num: none) = {
    if headers.numbering { if num != none { [#num. #it.body] } else { it } } else { it.body }
  }

  set text(
    size: layout.font-size,
    font: ("Roboto", "Arial", "Helvetica", "Liberation Sans", "DejaVu Sans"),
    lang: "en",
    region: "gb"
  )
  _container-inset.update(layout.container-inset)
  set par(leading: layout.leading, spacing: layout.par-spacing)
  set list(spacing: layout.list-spacing, indent: layout.list-indent)
  set enum(spacing: layout.list-spacing, indent: layout.list-indent)
  set heading(numbering: "1.1.")

  show heading.where(level: 1): it => {
    set text(white, size: layout.font-size)
    set align(headers.align)

    block(
      radius: corner,
      inset: 1.0mm,
      width: 100%,
      above: layout.heading-above,
      below: layout.heading-below,
      fill: get-color(location: it.location()),
      get-numbered-heading(it)
    )
  }

  show selector.or(
    heading.where(level: 2),
    heading.where(level: 3),
  ): it => {
    let num = counter(heading).at(it.location()).last()
    let stroke-style = if it.level == 3 { "dashed" } else { none }
    let weight = if it.level == 3 { "regular" } else { "bold" }

    box(inset: (bottom: 0.4em), grid(
      columns: (1fr, auto, 1fr),
      align: horizon + start,
      column-gutter: 1em,
      line(length: 100%, stroke: (
        paint: get-color(location: it.location()),
        dash: stroke-style,
        cap: "round"
      )),
      text(
        fill: get-color(location: it.location()),
        weight: weight,
        size: layout.font-size,
      )[#get-numbered-heading(it, num: num)],
      line(length: 100%, stroke: (
        paint: get-color(location: it.location()),
        dash: stroke-style,
        cap: "round"
      )),
    ))
  }

  show figure: set figure(supplement: [])

  columns(layout.columns.count, gutter: layout.columns.gutter, body)
}
