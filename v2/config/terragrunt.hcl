include "root" {
  path = find_in_parent_folders()
}

dependency "base" {
  config_path = "../base"
  skip_outputs = true
}
