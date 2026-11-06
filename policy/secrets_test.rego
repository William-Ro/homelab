package main

import rego.v1

test_plain_secret_denied if {
	count(deny_plaintext_secret) == 1 with input as {"kind": "Secret", "metadata": {"name": "x"}}
		with data.conftest.file.name as "apps/a/config/secret.yaml"
}

test_sops_secret_allowed if {
	count(deny_plaintext_secret) == 0 with input as {"kind": "Secret", "metadata": {"name": "x"}}
		with data.conftest.file.name as "apps/a/config/token.secret.sops.yaml"
}

test_external_secret_allowed if {
	count(deny_plaintext_secret) == 0 with input as {"kind": "ExternalSecret", "metadata": {"name": "x"}}
		with data.conftest.file.name as "apps/a/config/external-secret.yaml"
}

test_sops_file_without_metadata_denied if {
	count(deny_unencrypted_sops_secret) == 1 with input as {"kind": "Secret", "metadata": {"name": "x"}}
		with data.conftest.file.name as "apps/a/config/token.secret.yaml"
}

test_plaintext_value_in_sops_file_denied if {
	count(deny_plaintext_secret_value) == 1 with input as {
		"kind": "Secret",
		"metadata": {"name": "x"},
		"sops": {"age": []},
		"stringData": {"token": "hunter2", "other": "ENC[AES256_GCM,data:abc]"},
	}
		with data.conftest.file.name as "apps/a/config/token.secret.yaml"
}

test_encrypted_sops_secret_allowed if {
	count(deny_unencrypted_sops_secret) + count(deny_plaintext_secret_value) == 0 with input as {
		"kind": "Secret",
		"metadata": {"name": "x"},
		"sops": {"age": []},
		"stringData": {"token": "ENC[AES256_GCM,data:abc]"},
	}
		with data.conftest.file.name as "apps/a/config/token.secret.yaml"
}
