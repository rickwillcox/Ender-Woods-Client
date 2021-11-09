extends "res://addons/gut/test.gd"

const YEILD_TIME : float = 1.5

var characters = 'abcdefghijklmnopqrstuvwxyz'
var numbers = '0123456789'
var test_username : String
var test_password : String
var test_wrong_username : String
var test_wrong_password : String
var test_junk_char : String


func before_all():
	randomize()
	test_username = generate_word(characters, 25) 
	test_password = generate_word(characters, 25).sha256_text()
	test_wrong_username = generate_word(characters, 25) 
	test_wrong_password = generate_word(characters, 25).sha256_text()
	test_junk_char = generate_word(characters, 25).sha256_text()

	
func test_all_tests():
	TestGlobals.is_test = true
	subtest_account_features(test_username, test_password, test_junk_char)
	
	

func subtest_account_features(username, password, junk_char):
	var new_account : bool = true
	
	### Create Account Features ###
	# Create a new account that doesnt exist
	Gateway.connect_to_server(username, password, new_account)
	yield(yield_for(YEILD_TIME), YIELD)
	assert_true(TestGlobals.test_create_account_result, "New Account - Creation")
	assert_eq(3, TestGlobals.test_message, "Message should be 3")
	TestGlobals.reset_all()
	
	# Create an account with a username that is too long
	Gateway.connect_to_server(username + junk_char, password, new_account)
	yield(yield_for(YEILD_TIME), YIELD)
	assert_false(TestGlobals.test_create_account_result, "New Account - Username too long")
	assert_eq(1, TestGlobals.test_message, "Message should be 1")
	TestGlobals.reset_all()
	
	# Create an account with a username that already exists
	Gateway.connect_to_server(username, password, new_account)
	yield(yield_for(YEILD_TIME), YIELD)
	assert_false(TestGlobals.test_create_account_result, "New Account - Username already taken")
	assert_eq(2, TestGlobals.test_message, "Message should be 2")
	TestGlobals.reset_all()
	
	### Login Account Features ###
	new_account = false
	# Login with username that does not exist
	Gateway.connect_to_server(username + junk_char, password, new_account)	
	yield(yield_for(YEILD_TIME), YIELD)
	assert_false(TestGlobals.test_login_request_result, "Login wrong username")
	assert_false(TestGlobals.test_auth_token.length() == 74, "Auth token should be notoken")
	Server.token = TestGlobals.test_auth_token
	Server.connect_to_server()
	TestGlobals.reset_all()
	
	# Login with wrong password
	Gateway.connect_to_server(username , password.left(10) + junk_char, new_account)	
	yield(yield_for(YEILD_TIME), YIELD)
	assert_false(TestGlobals.test_login_request_result, "Login wrong password")
	assert_false(TestGlobals.test_auth_token.length() == 74, "Auth token should be notoken")
	TestGlobals.reset_all()
	
	# Login with username that doesnt exist
	Gateway.connect_to_server(username.left(10), password, new_account)	
	yield(yield_for(YEILD_TIME), YIELD)
	assert_false(TestGlobals.test_login_request_result, "Login incorrect account")

	# Login with username that does exist
	Gateway.connect_to_server(username, password, new_account)	
	yield(yield_for(YEILD_TIME), YIELD)
	assert_true(TestGlobals.test_login_request_result, "Login correct account")
	
	# Connect to the World Server with wrong auth token
	Server.token = TestGlobals.test_auth_token + junk_char
	Server.connect_to_server()
	yield(yield_for(YEILD_TIME), YIELD)
	assert_true(TestGlobals.connected_to_world_server, "Connected to world server")
	yield(yield_for(YEILD_TIME), YIELD)
	assert_false(TestGlobals.world_server_verification_results, "Wrong Auth Token results")
	TestGlobals.reset_all()
	
	# Connect to the World Server with correct auth token
	# cant get this part working yet.
#	Server.token = TestGlobals.test_auth_token
#	print("Server token: ", Server.token)
#	Server.connect_to_server()
#	yield(yield_for(YEILD_TIME), YIELD)
#	assert_true(TestGlobals.connected_to_world_server, "Connected to world server")
#	yield(yield_for(YEILD_TIME), YIELD)
#	assert_true(TestGlobals.world_server_verification_results, "Correct Auth Token results")
	
func generate_word(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi()% n_char]
	return word
