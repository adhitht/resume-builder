#import "components.typ": *
#import "utils.typ": *
#import "imports.typ": *

#let render_resume(
  selected_tags: (),
  selected_ids: (),
  exclude_tags: (),
  exclude_ids: (),
  section_order: ("education", "experience", "projects", "skills", "achievements", "volunteering"),
  show_gpa: true,
  max_experience: none,
  max_projects: none,
) = {
  import_yaml()

  let filtered_education = filter_entries(education_data, selected_tags, selected_ids, exclude_tags, exclude_ids)
  let filtered_experience = filter_entries(experience_data, selected_tags, selected_ids, exclude_tags, exclude_ids)
  let filtered_projects = filter_entries(projects_data, selected_tags, selected_ids, exclude_tags, exclude_ids)
  let filtered_skills = filter_entries(skills_data, selected_tags, selected_ids, exclude_tags, exclude_ids)
  let filtered_achievements = filter_entries(achievements_data, selected_tags, selected_ids, exclude_tags, exclude_ids)
  let filtered_volunteering = filter_entries(volunteering_data, selected_tags, selected_ids, exclude_tags, exclude_ids)

  if max_experience != none {
    filtered_experience = filtered_experience.slice(0, calc.min(max_experience, filtered_experience.len()))
  }
  if max_projects != none {
    filtered_projects = filtered_projects.slice(0, calc.min(max_projects, filtered_projects.len()))
  }

  set document(title: personal_data.name + " - Resume")
  set page(
    paper: "us-letter",
    margin: (x: 0.5in, y: 0.5in),
  )
  set text(
    font: "New Computer Modern",
    size: 11pt,
    fill: rgb("#000000")
  )
  set par(justify: true)

  render_header(personal_data)

  for section in section_order {
    if section == "education" and filtered_education.len() > 0 {
      render_education_section(filtered_education, show_gpa: show_gpa)
    } else if section == "experience" and filtered_experience.len() > 0 {
      render_experience_section(filtered_experience)
    } else if section == "projects" and filtered_projects.len() > 0 {
      render_projects_section(filtered_projects)
    } else if section == "skills" and filtered_skills.len() > 0 {
      render_skills_section(filtered_skills)
    } else if section == "achievements" and filtered_achievements.len() > 0 {
      render_achievements_section(filtered_achievements)
    } else if section == "volunteering" and filtered_volunteering.len() > 0 {
      render_volunteering_section(filtered_volunteering)
    }
  }
}
