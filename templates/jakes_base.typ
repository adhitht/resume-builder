#import "jakes.typ": resume, header, resume_heading, edu_item, exp_item, project_item, skill_item
#import "utils.typ": *

#let render_jakes_education_section(entries, show_gpa: true) = {
  resume_heading[Education]
  for entry in entries {
    let degree_text = if show_gpa and "gpa" in entry {
      entry.degree + ", GPA: " + entry.gpa
    } else {
      entry.degree
    }

    edu_item(
      name: entry.school,
      degree: degree_text,
      location: entry.location,
      date: entry.duration
    )
  }
}

#let render_jakes_experience_section(entries) = {
  resume_heading[Experience]
  for entry in entries {
    let highlight_blocks = ()
    for highlight in entry.highlights {
      highlight_blocks.push([#highlight])
    }

    exp_item(
      role: entry.title,
      name: if "organization" in entry { entry.organization } else { entry.company },
      location: entry.location,
      date: entry.duration,
      ..highlight_blocks
    )
  }
}

#let render_jakes_projects_section(entries) = {
  resume_heading[Projects]
  for entry in entries {
    let highlight_blocks = ()
    for highlight in entry.highlights {
      highlight_blocks.push([#highlight])
    }

    project_item(
      name: entry.name,
      skills: if "technologies" in entry { entry.technologies.join(", ") } else { "" },
      date: entry.duration,
      ..highlight_blocks
    )
  }
}

#let render_jakes_skills_section(entries) = {
  resume_heading[Technical Skills]
  for entry in entries {
    skill_item(
      category: entry.category,
      skills: entry.items.join(", ")
    )
  }
}

#let render_jakes_achievements_section(entries) = {
  resume_heading[Achievements]
  for entry in entries {
    project_item(
      name: entry.title,
      skills: "",
      date: entry.year,
      [#entry.description]
    )
  }
}

#let render_jakes_volunteering_section(entries) = {
  resume_heading[Volunteering]
  for entry in entries {
    exp_item(
      role: "Volunteer",
      name: entry.organization,
      location: "",
      date: "",
      [#entry.description]
    )
  }
}

#let render_jakes_resume(
  section_order: ("education", "experience", "projects", "skills"),
  show_gpa: true,
  max_experience: none,
  max_projects: none,
  include_education: (),
  include_experience: (),
  include_projects: (),
  include_skills: (),
  include_achievements: (),
  include_volunteering: (),
) = {
  let personal_data = yaml("../content/personal.yaml").personal
  let education_data = yaml("../content/education.yaml").education
  let experience_data = yaml("../content/experience.yaml").experience
  let projects_data = yaml("../content/projects.yaml").projects
  let skills_data = yaml("../content/skills.yaml").skills
  let achievements_data = yaml("../content/achievements.yaml").achievements
  let volunteering_data = yaml("../content/volunteering.yaml").volunteering

  let filter_by_ids(data, ids) = data.filter(x => ids.contains(x.id))

  let filtered_education = filter_by_ids(education_data, include_education)
  let filtered_experience = filter_by_ids(experience_data, include_experience)
  let filtered_projects = filter_by_ids(projects_data, include_projects)
  let filtered_achievements = filter_by_ids(achievements_data, include_achievements)
  let filtered_volunteering = filter_by_ids(volunteering_data, include_volunteering)
  let filtered_skills = filter_by_ids(skills_data, include_skills)

  if max_experience != none {
    filtered_experience = filtered_experience.slice(0, calc.min(max_experience, filtered_experience.len()))
  }
  if max_projects != none {
    filtered_projects = filtered_projects.slice(0, calc.min(max_projects, filtered_projects.len()))
  }

  show: resume

  header(
    name: personal_data.name,
    phone: personal_data.phone,
    email: personal_data.email,
    linkedin: if "linkedin" in personal_data { personal_data.linkedin } else { "" },
    site: if "github" in personal_data { personal_data.github } else { "" },
  )

  for section in section_order {
    if section == "education" and filtered_education.len() > 0 {
      render_jakes_education_section(filtered_education, show_gpa: show_gpa)
    } else if section == "experience" and filtered_experience.len() > 0 {
      render_jakes_experience_section(filtered_experience)
    } else if section == "projects" and filtered_projects.len() > 0 {
      render_jakes_projects_section(filtered_projects)
    } else if section == "skills" and filtered_skills.len() > 0 {
      render_jakes_skills_section(filtered_skills)
    } else if section == "achievements" and filtered_achievements.len() > 0 {
      render_jakes_achievements_section(filtered_achievements)
    } else if section == "volunteering" and filtered_volunteering.len() > 0 {
      render_jakes_volunteering_section(filtered_volunteering)
    }
  }
}
