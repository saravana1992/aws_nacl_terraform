
variable "environment" { 
   description = "To identify the environment to which this resource belongs to"
   default = "qa"
 }
 

variable "vpc_cidr" { 
	description = "To identify the IP range assigned to VPC"
    default = "10.0.0.0/24"
	}

variable "project" { 
	description = "To identify the project to which this resource belongs to"
	default = "Alvin"
	}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b"]
  type=list(string)
  description = "List of availabilty zones in the region to be used"
}

variable "public_subnets_cidr" {
  default = ["10.0.0.0/26","10.0.0.128/26"]
  type=list(string)
  description = "List of IP ranges for the public subnets where all resources need to be created."
}

variable "private_subnets_cidr" {
  default = ["10.0.0.64/26","10.0.0.192/26"]
  type=list(string)
  description = "List of IP ranges for the private subnets where all resources need to be created."
}

variable "tag" { 
   description = "Resource tagging policy version - ideally managed at the Altus as organisation level, not project specific"
   default = "test"
   }

variable "organisation" { 
	description = "To identify the organisation" 
	default = "test-org"
}

variable "business_owner" { 
   description = "Name of the person - To easily identify who is the business person responsible for the service/resource." 
   default = "qa"
   }

