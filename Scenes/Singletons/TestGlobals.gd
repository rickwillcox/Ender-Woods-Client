extends Node

# This changes to true when the tests are run.
var is_test : bool = false

var test_create_account_result : bool 
var test_message : int
var test_auth_token : String = ""
var test_login_request_result : bool
var connected_to_world_server : bool
var world_server_verification_results : bool

func reset_all():
	test_create_account_result = false
	test_message = 0
	test_auth_token = ""
	test_login_request_result = false
	connected_to_world_server = false
	world_server_verification_results = false
