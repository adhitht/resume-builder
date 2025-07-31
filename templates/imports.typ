#let import_yaml() ={
  let personal_data = yaml("../content/personal.yaml").personal
  let education_data = yaml("../content/education.yaml").education
  let experience_data = yaml("../content/experience.yaml").experience
  let projects_data = yaml("../content/projects.yaml").projects
  let skills_data = yaml("../content/skills.yaml").skills
  let achievements_data = yaml("../content/achievements.yaml").achievements
  let volunteering_data = yaml("../content/volunteering.yaml").volunteering
}