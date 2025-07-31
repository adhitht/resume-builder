// utils.typ - Utility functions for data filtering and processing

#let load_yaml(path) = {
  yaml(path)
}

// Filter entries based on tags and IDs
#let filter_entries(entries, selected_tags, selected_ids, exclude_tags, exclude_ids) = {
  let filtered = entries
  
  // If specific IDs are selected, only include those
  if selected_ids.len() > 0 {
    filtered = filtered.filter(entry => selected_ids.contains(entry.id))
  }
  
  // If specific tags are selected, only include entries with those tags
  if selected_tags.len() > 0 {
    filtered = filtered.filter(entry => {
      if "tags" not in entry { return false }
      selected_tags.any(tag => entry.tags.contains(tag))
    })
  }
  
  // Exclude entries with specific IDs
  if exclude_ids.len() > 0 {
    filtered = filtered.filter(entry => not exclude_ids.contains(entry.id))
  }
  
  // Exclude entries with specific tags
  // if exclude_tags.len() > 0 {
  //   filtered = filtered.filter(entry => {
  //     if "tags" not in entry { return true }
  //     // not exclude_tags.any(tag => entry.tags.contains(tag))
  //   })
  // }
  
  return filtered
}

// Sort entries by priority (if priority field exists) or by date
#let sort_entries(entries, sort_by: "date", reverse: true) = {
  if sort_by == "priority" {
    entries.sorted(key: entry => {
      if "priority" in entry { entry.priority } else { 0 }
    }, reverse: reverse)
  } else if sort_by == "date" {
    entries.sorted(key: entry => {
      if "duration" in entry {
        let duration_str = str(entry.duration)
        let matches = duration_str.matches(regex("\d{4}"))
        if matches.len() > 0 {
          int(matches.last().text)
        } else { 0 }
      } else { 0 }
    }, reverse: reverse)
  } else {
    entries
  }
}

// Get entries by company/organization type
#let filter_by_company_type(entries, company_types) = {
  entries.filter(entry => {
    if "tags" not in entry { return false }
    company_types.any(type => entry.tags.contains(type))
  })
}

// Prioritize current/recent experiences
#let prioritize_current(entries) = {
  let current = entries.filter(entry => {
    if "tags" not in entry { return false }
    entry.tags.contains("current")
  })
  let others = entries.filter(entry => {
    if "tags" not in entry { return true }
    not entry.tags.contains("current")
  })
  current + others
}

// Utility to truncate text
#let truncate_text(text, max_length) = {
  if text.len() <= max_length {
    text
  } else {
    text.slice(0, max_length - 3) + "..."
  }
}

// Calculate total experience in years (rough estimation)
#let calculate_experience_years(entries) = {
  // This is a simplified calculation
  // In practice, you might want more sophisticated date parsing
  entries.len() * 0.5 // Rough estimate: 6 months per role on average
}

// Get unique technologies from filtered entries
#let get_technologies(entries) = {
  let all_techs = ()
  for entry in entries {
    if "technologies" in entry {
      all_techs = all_techs + entry.technologies
    }
  }
  // Remove duplicates (Typst doesn't have a built-in unique function)
  let unique_techs = ()
  for tech in all_techs {
    if not unique_techs.contains(tech) {
      unique_techs.push(tech)
    }
  }
  unique_techs
}