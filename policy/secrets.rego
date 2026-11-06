package main

import rego.v1

is_sops_file if endswith(data.conftest.file.name, ".secret.yaml")

is_sops_file if endswith(data.conftest.file.name, ".secret.sops.yaml")

deny_plaintext_secret contains msg if {
	input.kind == "Secret"
	not is_sops_file
	msg := sprintf("Secret %q must be an ExternalSecret or a SOPS-encrypted *.secret.yaml file", [input.metadata.name])
}

deny_unencrypted_sops_secret contains msg if {
	input.kind == "Secret"
	is_sops_file
	not input.sops
	msg := sprintf("Secret %q has no sops metadata; encrypt it with `sops --encrypt`", [input.metadata.name])
}

deny_plaintext_secret_value contains msg if {
	input.kind == "Secret"
	is_sops_file
	some field in ["data", "stringData"]
	some key, value in input[field]
	not startswith(value, "ENC[")
	msg := sprintf("Secret %q %s.%s is not encrypted", [input.metadata.name, field, key])
}
