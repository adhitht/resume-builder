// components.typ - Reusable resume components

// Header component
#let render_header(personal) = {
  align(center)[
    #text(size: 24pt, weight: "bold")[#upper(personal.name)]
    #v(4pt)
    #text(size: 10pt)[
      #personal.phone |
      #link("mailto:" + personal.email)[#personal.email] |
      #link(personal.linkedin)[LinkedIn] |
      #link(personal.github)[GitHub]
    ]
  ]
  v(12pt)
}

// Section header
#let section_header(title) = {
  v(8pt)
  text(size: 12pt, weight: "bold")[#upper(title)]
  v(2pt)
  line(length: 100%, stroke: 0.5pt + black)
  v(6pt)
}

// Education entry
#let render_education_entry(entry, show_gpa: true) = {
  let gpa_text = if show_gpa and "gpa" in entry { " | GPA: " + entry.gpa } else { "" }
  
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [
      *#entry.school* #h(1em) _#entry.location \
      _#entry.degree#gpa_text
    ],
    [
      *#entry.duration*
    ]
  )
  v(4pt)
}

// Experience entry
#let render_experience_entry(entry) = {
  // Main header
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [
      *#entry.title* #h(1em) _#entry.location \
      _#entry.company#if "organization" in entry [ -- #entry.organization]
    ],
    [
      *#entry.duration*
    ]
  )
  
  v(2pt)
  
  // Highlights
  for highlight in entry.highlights [
    • #highlight \
  ]
  
  // Technologies (if present)
  if "technologies" in entry and entry.technologies.len() > 0 [
    v(2pt)
    _Technologies: #entry.technologies.join(", ")_
  ]
  
  v(6pt)
}

// Project entry
#let render_project_entry(entry) = {
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [
      *#entry.name* | _#entry.technologies.join(", ")_
    ],
    [
      *#entry.duration*
    ]
  )
  
  v(2pt)
  
  for highlight in entry.highlights [
    • #highlight \
  ]
  
  v(6pt)
}

// Skills entry
#let render_skills_entry(entry) = {
  [*#entry.category*: #entry.items.join(", ")]
}

// Achievement entry
#let render_achievement_entry(entry) = {
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [
      *#entry.title*
    ],
    [
      *#entry.year*
    ]
  )
  
  v(2pt)
  
  [• #entry.description]
  
  v(6pt)
}

// Volunteering entry
#let render_volunteering_entry(entry) = {
  [*#entry.organization*: #entry.description]
}

// Section renderers
#let render_education_section(entries, show_gpa: true) = {
  section_header("Education")
  for entry in entries {
    render_education_entry(entry, show_gpa: show_gpa)
  }
}

#let render_experience_section(entries) = {
  section_header("Experience")
  for entry in entries {
    render_experience_entry(entry)
  }
}

#let render_projects_section(entries) = {
  section_header("Projects")
  for entry in entries {
    render_project_entry(entry)
  }
}

#let render_skills_section(entries) = {
  section_header("Technical Skills")
  for (i, entry) in entries.enumerate() {
    render_skills_entry(entry)
    if i < entries.len() - 1 [ \ ]
  }
  v(6pt)
}

#let render_achievements_section(entries) = {
  section_header("Achievements")
  for entry in entries {
    render_achievement_entry(entry)
  }
}

#let render_volunteering_section(entries) = {
  section_header("Volunteering")
  for (i, entry) in entries.enumerate() {
    render_volunteering_entry(entry)
    if i < entries.len() - 1 [ \ ]
  }
  v(6pt)
}