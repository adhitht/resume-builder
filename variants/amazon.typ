#import "../templates/jakes_base.typ": render_jakes_resume

#render_jakes_resume(
  selected_tags: ("amazon", "backend", "fullstack"),
  exclude_tags: ("basic"),
  section_order: ("education", "experience", "projects", "skills"),
  show_gpa: false,
  max_experience: 4,
  max_projects: 3,
)