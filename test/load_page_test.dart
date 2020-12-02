import 'package:flutter_test/flutter_test.dart';
import 'package:gantt_flutter/calendar_demo/http_data/load_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

main() {
  group('fetchLoadData', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();

      // Use Mockito to return a successful response when it calls the
      // provided http.Client.
      when(client.get('localhost:8080/test/load')).thenAnswer((_) async =>
          http.Response(
              '{"rows":[{"id":"1","date":"2017-10-01"},{"id":"2","date":"2017-10-02"},{"id":"3","date":"2017-10-03"}],"loads":[{"id":"1","resource":"Line 1","percent":13},{"id":"1","resource":"Line 2","percent":28},{"id":"1","resource":"Tang Sanzang","percent":43},{"id":"1","resource":"Sun Wukong","percent":66},{"id":"1","resource":"Zhu Bagai","percent":83},{"id":"1","resource":"Sha Wujing","percent":100},{"id":"2","resource":"Line 1","percent":23},{"id":"2","resource":"Line 2","percent":38},{"id":"2","resource":"Tang Sanzang","percent":53},{"id":"2","resource":"Sun Wukong","percent":76},{"id":"2","resource":"Zhu Bagai","percent":93},{"id":"2","resource":"Sha Wujing","percent":90},{"id":"3","resource":"Line 1","percent":33},{"id":"3","resource":"Line 2","percent":48},{"id":"3","resource":"Tang Sanzang","percent":63},{"id":"3","resource":"Sun Wukong","percent":86},{"id":"3","resource":"Zhu Bagai","percent":83},{"id":"3","resource":"Sha Wujing","percent":80}],"human":75,"device":86}',
              200));

      // expect(await fetchLoadData(client, DateTime.now()), isA<LoadPageData>());
    });
  });
}
