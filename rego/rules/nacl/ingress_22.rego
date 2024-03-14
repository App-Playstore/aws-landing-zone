package rules.tf_aws_vpc_nacl_ingress_22

import data.aws.vpc.nacl_library as lib
import data.fugue

__rego__metadoc__ := {
  "custom": {
    "controls": {
			"COBIT_DETAILS": [
	          "DSS05.02.6",
            "DSS05.03.5"
	        ],
	        "COBIT_IMPLEMENTATION": [
	          "DSS05.02.6",
            "DSS05.03.5"
	        ],
	        "COBIT_DEFINITION": [
	          "DSS05.02.2",
            "DSS05.02.3"
	        ],
    },
    "severity": "High"
  },
  "description": "VPC network ACLs should not allow ingress from 0.0.0.0/0 to port 22. Public access to remote server administration ports, such as 22 and 3389, increases resource attack surface and unnecessarily raises the risk of resource compromise.",
  "id": "FR50,FR51",
  "title": "VPC network ACLs should not allow ingress from 0.0.0.0/0 to port 22"
}

resource_type := "MULTIPLE"

nacls = fugue.resources("aws_network_acl")

lower_deny(deny, allow) {
  deny < allow
}

is_good_nacl(nacl) {
  allow = lib.lowest_allow_ingress_zero_cidr_by_port(nacl, 22)
  deny = lib.lowest_deny_ingress_zero_cidr_by_port(nacl, 22)
  lower_deny(deny, allow)
} {
  not lib.lowest_allow_ingress_zero_cidr_by_port(nacl, 22)
}

policy[j] {
  nacl = nacls[_]
  is_good_nacl(nacl)
  j = fugue.allow_resource(nacl)
} {
  nacl = nacls[_]
  not is_good_nacl(nacl)
  j = fugue.deny_resource(nacl)
}