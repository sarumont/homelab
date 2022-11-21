include "root" {
  path = find_in_parent_folders()
}

dependency "mariadb" {
  config_path = "../mariadb"
}

inputs = {
  db_root_password = dependency.mariadb.outputs.mariadb_root_password
}
