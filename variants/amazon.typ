#import "../templates/jakes_base.typ": render_jakes_resume

#render_jakes_resume(
  section_order: ("education", "experience", "projects", "skills", "achievements", "volunteering"),
  show_gpa: false,
  include_education: ("iit_hyderabad"),
  include_experience: ("fullstack_developer", "backend_developer"),
  include_projects: ("resume-builder"),
  include_skills: ("languages"),
  include_achievements: ("hackathon"),
  include_volunteering: ("red_cross"),
)
