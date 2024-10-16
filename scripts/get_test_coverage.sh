dart pub global activate coverage
dart pub global run coverage:test_with_coverage
lcov --remove coverage/lcov.info 'lib/src/message_parser/*' 'lib/src/generated/*' -o coverage/new_lcov.info
genhtml coverage/new_lcov.info --output=coverage
