variable "create_ipa" {
  type    = bool
  default = ${FREE_IPA}
}

variable "create_kts" {
  type    = bool
  default = ${ENCRYPTION_ACTIVATED}
}