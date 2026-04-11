variable "traffic_manager_endpoint_name" {
  type        = string
  description = "The name of the Traffic Manager endpoint."
}

variable "traffic_manager_profile_id" {
  type        = string
  description = "The ID of the Traffic Manager profile."
}

variable "priority" {
  type        = number
  description = "The weight of this endpoint when using the 'Weighted' traffic routing method. Possible values are from 1 to 1000."
}

variable "traffic_manager_endpoint_target_resource_id" {
  type        = string
  description = "The Azure Resource URI of the endpoint. Not applicable to endpoints of type 'ExternalEndpoints'."
}
