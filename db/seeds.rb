# Seed the built-in violation categories.
#
# These are sensible defaults for a municipal parking enforcement workflow.
# Site administrators can edit, deactivate, or add to this list once the
# admin UI ships. The list is idempotent — running `db:seed` repeatedly is safe.
CATEGORY_NAMES = [
  "Parking in crosswalk",
  "Parking in handicapped spot",
  "Parking in front of fire hydrant",
  "Parking without valid permit",
  "Parking too close to corner",
  "Parking blocking driveway",
  "Parking in bike lane",
  "Double parking",
  "Other illegal parking"
].freeze

CATEGORY_NAMES.each_with_index do |name, index|
  category = Category.find_or_initialize_by(name: name)
  category.position = index
  category.active = true
  category.save!
end

puts "Seeded #{Category.count} categories."

# Seed the default resolution types officers can use to close out an issue.
RESOLUTION_TYPE_NAMES = [
  "Summons issued",
  "Violation no longer present",
  "Not illegal"
].freeze

RESOLUTION_TYPE_NAMES.each_with_index do |name, index|
  rt = ResolutionType.find_or_initialize_by(name: name)
  rt.position = index
  rt.active = true
  rt.save!
end

puts "Seeded #{ResolutionType.count} resolution types."
