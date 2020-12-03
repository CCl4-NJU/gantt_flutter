import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_flutter/calendar_demo/http_data/gantt_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchResourceData', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get('localhost:8080/test/resource')).thenAnswer((_) async =>
          http.Response(
              '{"products":[{"id":"1","name":"product 1"},{"id":"2","name":"product 2"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-7-0","endTime":"2018-1-1-9-0","productId":"1"},{"id":"2","name":"Line 1","startTime":"2018-1-1-9-0","endTime":"2018-1-1-17-0","productId":"2"},{"id":"3","name":"Li Si","startTime":"2018-1-1-7-0","endTime":"2018-1-1-9-0","productId":"1"},{"id":"4","name":"Li Si","startTime":"2018-1-1-9-0","endTime":"2018-1-1-17-0","productId":"2"}]}',
              200));

      // var fetch = fetchResourceData(client, DateTime.now());

      // expect(await fetch, isA<GanttPageData>());
    });
  });
}
