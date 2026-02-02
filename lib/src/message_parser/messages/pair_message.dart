// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This package is copied from the Dart SDK as is
// ignore_for_file: public_member_api_docs

import 'message.dart';

class PairMessage<T extends Message, S extends Message> extends Message {
  final T first;
  final S second;

  PairMessage(this.first, this.second, [Message? parent]) : super(parent);

  @override
  String expanded([
    String Function(dynamic, dynamic) transform = nullTransform,
  ]) => [first, second].map((chunk) => transform(this, chunk)).join('');

  @override
  String toCode() => [first, second].map((each) => each.toCode()).join('');

  @override
  Object toJson() => [first, second].map((each) => each.toJson()).toList();
}
