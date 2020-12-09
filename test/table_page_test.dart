import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_flutter/calendar_demo/http_data/table_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchResourceTableData', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get('localhost:8080/test/resourceInfo')).thenAnswer(
          (_) async => http.Response(
              '{"human":[{"id":"1","name":"Tong Xiaoling","number":5,"shift":2},{"id":"2","name":"Wang Xiaohu","number":4,"shift":3},{"id":"3","name":"Zhang Xiaoming","number":10,"shift":3},{"id":"4","name":"Chen Xiaohong","number":7,"shift":2},{"id":"5","name":"Liu Xiaojia","number":3,"shift":3},{"id":"6","name":"Tong Xiaoling","number":5,"shift":2}],"device":[{"id":"1","name":"Line 1","number":4,"shift":1},{"id":"2","name":"Line 2","number":3,"shift":1},{"id":"3","name":"Line 3","number":4,"shift":1},{"id":"4","name":"Line 4","number":1,"shift":1}]}',
              200));

      expect(
          await fetchResourceTableData(client), isA<ResourceTablePageData>());
    });
  });
}
