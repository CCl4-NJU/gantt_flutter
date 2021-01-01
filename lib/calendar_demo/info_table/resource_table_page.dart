import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_model.dart';
import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_view.dart';
import 'package:gantt_flutter/calendar_demo/http_data/table_data.dart';
import 'package:gantt_flutter/models.dart';

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class ResourceTableDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ResourceTableDemoPageState();
  }
}

class _ResourceTableDemoPageState extends State<ResourceTableDemoPage> {
  Future<ResourceTablePageData> futureResourceTable;

  List<ResourceData> _human_resources;
  List<ResourceData> _device_resources;

  @override
  void initState() {
    super.initState();

    _human_resources = new List<ResourceData>();
    _device_resources = new List<ResourceData>();

    mockResourceTableConfig();
    futureResourceTable = fetchResourceTableData(client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Resource Info'),
          backgroundColor: Theme.of(context).primaryColor),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder<ResourceTablePageData>(
          future: futureResourceTable,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _human_resources.clear();
              _device_resources.clear();

              _human_resources.addAll(snapshot.data.human
                  .map((item) => ResourceData(
                      item.id,
                      item.name,
                      item.number.toString(),
                      item.shift == 1
                          ? 'day & night'
                          : (item.shift == 2 ? 'day' : 'night')))
                  .toList());

              _device_resources.addAll(snapshot.data.device
                  .map((item) => ResourceData(
                      item.id,
                      item.name,
                      item.number.toString(),
                      item.shift == 1
                          ? 'day & night'
                          : (item.shift == 2 ? 'day' : 'night')))
                  .toList());

              return QuickSwitchView(
                  primary:
                      QuickSwitchModel("Human", _buildTable(_human_resources)),
                  secondary: QuickSwitchModel(
                      "Device", _buildTable(_device_resources)));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
      ),
    );
  }

  Widget _buildTable(List<ResourceData> resource_list) {
    List<DataRow> data_row = new List<DataRow>();
    for (int i = 0; i < resource_list.length; i++) {
      ResourceData data = resource_list[i];
      data_row.add(DataRow(cells: [
        DataCell(Text(data.name)),
        DataCell(Text(data.number)),
        DataCell(Text(data.shift))
      ]));
    }
    return ListView(children: [
      DataTable(columns: [
        DataColumn(
            label: Text('Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Number',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Shift',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ], rows: data_row)
    ]);
  }
}

void mockResourceTableConfig() {
  String response_resource_info =
      '{"human":[{"id":"1","name":"Tong Xiaoling","number":5,"shift":2},{"id":"2","name":"Wang Xiaohu","number":4,"shift":3},{"id":"3","name":"Zhang Xiaoming","number":10,"shift":3},{"id":"4","name":"Chen Xiaohong","number":7,"shift":2},{"id":"5","name":"Liu Xiaojia","number":3,"shift":3},{"id":"6","name":"Tong Xiaoling","number":5,"shift":2},{"id":"7","name":"Tong Xiaoling","number":5,"shift":2},{"id":"8","name":"Wang Xiaohu","number":4,"shift":3},{"id":"9","name":"Zhang Xiaoming","number":10,"shift":3},{"id":"10","name":"Chen Xiaohong","number":7,"shift":2},{"id":"11","name":"Liu Xiaojia","number":3,"shift":3},{"id":"12","name":"Tong Xiaoling","number":5,"shift":2},{"id":"13","name":"Tong Xiaoling","number":5,"shift":2},{"id":"14","name":"Wang Xiaohu","number":4,"shift":3},{"id":"15","name":"Zhang Xiaoming","number":10,"shift":3},{"id":"16","name":"Chen Xiaohong","number":7,"shift":2},{"id":"17","name":"Liu Xiaojia","number":3,"shift":3},{"id":"18","name":"Tong Xiaoling","number":5,"shift":2},{"id":"19","name":"Tong Xiaoling","number":5,"shift":2},{"id":"20","name":"Wang Xiaohu","number":4,"shift":3},{"id":"21","name":"Zhang Xiaoming","number":10,"shift":3},{"id":"22","name":"Chen Xiaohong","number":7,"shift":2},{"id":"23","name":"Liu Xiaojia","number":3,"shift":3},{"id":"24","name":"Tong Xiaoling","number":5,"shift":2}],"device":[{"id":"1","name":"Line 1","number":4,"shift":1},{"id":"2","name":"Line 2","number":3,"shift":1},{"id":"3","name":"Line 3","number":4,"shift":1},{"id":"4","name":"Line 4","number":1,"shift":1},{"id":"5","name":"Line 1","number":4,"shift":1},{"id":"6","name":"Line 2","number":3,"shift":1},{"id":"7","name":"Line 3","number":4,"shift":1},{"id":"8","name":"Line 4","number":1,"shift":1},{"id":"9","name":"Line 1","number":4,"shift":1},{"id":"10","name":"Line 2","number":3,"shift":1},{"id":"11","name":"Line 3","number":4,"shift":1},{"id":"12","name":"Line 4","number":1,"shift":1},{"id":"13","name":"Line 1","number":4,"shift":1},{"id":"14","name":"Line 2","number":3,"shift":1},{"id":"15","name":"Line 3","number":4,"shift":1},{"id":"16","name":"Line 4","number":1,"shift":1}]}';
  when(client.get('localhost:8080/resource/info'))
      .thenAnswer((_) async => http.Response(response_resource_info, 200));
}
