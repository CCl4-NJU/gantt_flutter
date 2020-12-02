import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_flutter/calendar_demo/http_data/progress_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchProgressData', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get('localhost:8080/progress')).thenAnswer((_) async =>
          http.Response(
              '{"orders": [{"id": "418575","delay": false}, {"id": "418477", "delay": true}], "crafts": [{"id": "418575", "name": "Assemble", "percent": 0.6}, {"id": "418477", "name": "Assemble", "percent": 0.23}, {"id": "418477", "name": "Test", "percent": 0.18}], "rate": 67}',
              200));

      // var fetch = fetchProgressData(client);

      // expect(await fetchProgressData(client), isA<ProgressPageData>());
    });
  });
}
