flutter test --coverage
lcov --remove coverage/lcov.info 'lib/src/message_parser/*' 'lib/src/generated/*' -o coverage/new_lcov.info
genhtml coverage/new_lcov.info --output=coverage