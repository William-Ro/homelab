package main

import rego.v1

test_misnamed_file_denied if {
	count(deny_file_naming) == 1 with data.conftest.file.name as "helmrelease.yaml"
}

test_hyphenated_name_allowed if {
	count(deny_file_naming) == 0 with data.conftest.file.name as "helm-release.yaml"
}
