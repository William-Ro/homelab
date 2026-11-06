package main

import rego.v1

misnamed := {"helmrelease.yaml": "helm-release.yaml", "ocirepository.yaml": "oci-repository.yaml"}

# conftest exposes only the basename in data.conftest.file.name.
deny_file_naming contains msg if {
	some wrong, right in misnamed
	data.conftest.file.name == wrong
	msg := sprintf("rename %s to %s", [wrong, right])
}
