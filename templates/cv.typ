// Template Typst universel et bilingue pour CV-as-Code
// Calibré pour tenir strictement sur 1 seule page A4 avec un rendu professionnel

#let default_data_path = "/data/cv_computed_fr.json"
#let data_path = sys.inputs.at("data_file", default: default_data_path)
#let data = json(data_path)

#set page(
  paper: "a4",
  margin: (x: 1.25cm, top: 1.0cm, bottom: 1.0cm),
)

#set text(
  font: ("Segoe UI", "Arial", "Roboto", "Liberation Sans"),
  size: 8.5pt,
  fill: rgb("#2d3748"),
  spacing: 110%,
  lang: data.at("lang", default: "fr")
)

#set list(
  spacing: 5pt,
  marker: [•],
  body-indent: 4pt
)

// Couleurs
#let primary = rgb("#1a202c")
#let secondary = rgb("#4a5568")
#let banner-bg = rgb("#edf2f7")
#let accent = rgb("#2b6cb0")
#let light-gray = rgb("#718096")

// Fonction d'en-tête de section avec bandeau stylisé
#let section-title(title) = {
  v(6pt)
  rect(
    fill: banner-bg,
    radius: 2.5pt,
    width: 100%,
    inset: (x: 7pt, y: 3.5pt),
    outset: 0pt,
    [
      #text(
        fill: primary,
        weight: "bold",
        size: 9pt,
        tracking: 1.2pt,
        upper(title)
      )
    ]
  )
  v(2.5pt)
}

// ==========================================
// HEADER : PHOTO + NOM & TITRE
// ==========================================
#grid(
  columns: (72pt, 1fr),
  column-gutter: 18pt,
  align: (center + horizon, left + horizon),
  [
    #if data.profile.at("has_photo", default: false) {
      block(
        radius: 100%,
        stroke: 1.5pt + rgb("#cbd5e0"),
        clip: true,
        width: 72pt,
        height: 72pt,
        image("/" + data.profile.photo, width: 72pt, height: 72pt, fit: "cover")
      )
    } else {
      circle(
        radius: 36pt,
        fill: banner-bg,
        stroke: 1.5pt + rgb("#cbd5e0"),
        align(center + horizon)[
          #text(size: 20pt, weight: "bold", fill: accent)[
            #data.profile.name.slice(0, 1)
          ]
        ]
      )
    }
  ],
  [
    #text(
      size: 20pt,
      weight: "bold",
      tracking: 2.5pt,
      fill: primary,
      upper(data.profile.name)
    )
    #v(2pt)
    #text(
      size: 11pt,
      weight: "medium",
      tracking: 1.5pt,
      fill: accent,
      upper(data.profile.title)
    )
  ]
)

#v(5pt)
#line(length: 100%, stroke: 0.5pt + rgb("#e2e8f0"))

// ==========================================
// CORPS : 2 COLONNES (Gauche: Contact/Skills, Droite: Exp/Formations)
// ==========================================
#grid(
  columns: (1fr, 2.1fr),
  column-gutter: 18pt,
  [
    // ----------------------------------------
    // COLONNE GAUCHE
    // ----------------------------------------
    #section-title(data.labels.contact)
    
    #text(weight: "bold")[#data.profile.name] \
    #if "address" in data.contact and data.contact.address != "" [
      #data.contact.address \
    ]
    #if "phone" in data.contact and data.contact.phone != "" [
      #data.contact.phone \
    ]
    #link("mailto:" + data.contact.email)[#text(fill: accent)[#data.contact.email]] \
    #if "github" in data.contact and data.contact.github != "" [
      #link(data.contact.github)[#text(fill: accent)[#data.contact.github.replace("https://", "")]] \
    ]
    #if "linkedin" in data.contact and data.contact.linkedin != "" [
      #link(data.contact.linkedin)[#text(fill: accent)[linkedin.com/in/noa-gaillard]] \
    ]
    #if "portfolio" in data.contact and data.contact.portfolio != "" [
      #link(data.contact.portfolio)[#text(fill: accent)[#data.contact.portfolio.replace("https://", "")]] \
    ]
    #if "birth_date" in data.contact and data.contact.birth_date != "" [
      #text(fill: light-gray, size: 8pt)[#data.labels.birth_date : #data.contact.birth_date] \
    ]

    #section-title(data.labels.skills_tech)
    #for group in data.skills.technical [
      #text(weight: "bold", fill: primary)[#group.category :] \
      #text(fill: secondary)[#group.items.join(", ")]
      #v(2.5pt)
    ]

    #section-title(data.labels.languages)
    #for lang in data.skills.languages [
      #grid(
        columns: (1fr, auto),
        [#text(weight: "medium")[#lang.language]],
        [#text(weight: "bold", fill: accent)[#lang.level]]
      )
    ]

    #if "other" in data.skills and data.skills.other.len() > 0 [
      #section-title(data.labels.other)
      #list(
        ..data.skills.other.map(item => text(fill: secondary)[#item])
      )
    ]
  ],
  [
    // ----------------------------------------
    // COLONNE DROITE
    // ----------------------------------------
    #section-title(data.labels.profile)
    #text(fill: secondary, size: 8.3pt)[
      #data.profile.summary
    ]

    #section-title(data.labels.education)
    #for edu in data.education [
      #text(weight: "bold", size: 8.8pt, fill: primary)[#edu.institution]
      #h(1fr)
      #text(size: 8pt, fill: light-gray)[#edu.period] \
      #text(weight: "medium", fill: accent)[#edu.degree] \
      #if "details" in edu [
        #v(-4pt)
        #list(
          ..edu.details.map(d => text(fill: secondary, size: 8pt)[#d])
        )
      ]
      #v(2pt)
    ]

    #section-title(data.labels.experiences)
    #if "experiences" in data and data.experiences.len() > 0 [
      #for exp in data.experiences [
        #text(weight: "bold", size: 8.8pt, fill: primary)[#exp.title]
        #h(1fr)
        #text(size: 7.8pt, fill: light-gray)[#exp.period] \
        #text(weight: "medium", size: 8.2pt, fill: accent)[#exp.organization] \
        #if "highlights" in exp [
          #v(-4pt)
          #list(
            ..exp.highlights.map(h => text(fill: secondary, size: 8pt)[#h])
          )
        ]
        #v(2pt)
      ]
    ]

    #section-title(data.labels.github_projects)
    #if "github_projects" in data and data.github_projects.len() > 0 [
      #for proj in data.github_projects [
        #grid(
          columns: (1fr, auto),
          [
            #text(weight: "bold", size: 8.5pt, fill: primary)[#proj.name]
            #if proj.is_private [
              #h(3pt)
              #text(size: 7.5pt, fill: light-gray)[#data.labels.internal_proj]
            ]
          ],
          [
            #text(weight: "bold", size: 7.8pt, fill: accent)[#proj.language]
          ]
        )
        #text(size: 8pt, fill: secondary)[#proj.description]
        #if proj.url != "" and not proj.is_private [
          #h(3pt)
          #link(proj.url)[#text(size: 7.5pt, fill: accent)[#data.labels.repo_link]]
        ]
        #v(2.5pt)
      ]
    ] else [
      #text(fill: light-gray, style: "italic")[#data.labels.no_projects]
    ]
  ]
)
