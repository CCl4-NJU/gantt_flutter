import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_model.dart';
import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_view.dart';
import 'package:gantt_flutter/calendar_demo/http_data/table_data.dart';
import 'package:gantt_flutter/models.dart';

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class OrderTableDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OrderTableDemoPageState();
  }
}

class _OrderTableDemoPageState extends State<OrderTableDemoPage> {
  Future<OrderTablePageData> futureOrderTable;

  List<OrderScheduleData> _order_schedule;
  List<OrderResourceData> _order_resource;

  @override
  void initState() {
    super.initState();

    _order_schedule = new List<OrderScheduleData>();
    _order_resource = new List<OrderResourceData>();

    mockOrderTableConfig();
    futureOrderTable = fetchOrderTableData(client);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Order Info'),
          backgroundColor: Theme.of(context).primaryColor),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder<OrderTablePageData>(
          future: futureOrderTable,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _order_schedule.clear();
              _order_resource.clear();

              _order_schedule.addAll(snapshot.data.order_schedule
                  .map((item) => OrderScheduleData(
                      item.id, item.sub_id, item.start, item.end))
                  .toList());

              _order_resource.addAll(snapshot.data.order_resource
                  .map((item) => OrderResourceData(
                      item.id,
                      item.sub_id,
                      item.resource_count.toString(),
                      item.time_count.toString()))
                  .toList());

              return QuickSwitchView(
                  primary: QuickSwitchModel(
                      "Schedule", _buildSchedule(_order_schedule)),
                  secondary: QuickSwitchModel(
                      "Resource", _buildResource(_order_resource)));
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

  Widget _buildSchedule(List<OrderScheduleData> schedule_list) {
    List<DataRow> data_row = new List<DataRow>();
    for (int i = 0; i < schedule_list.length; i++) {
      OrderScheduleData data = schedule_list[i];
      data_row.add(DataRow(cells: [
        DataCell(Text(data.id)),
        DataCell(Text(data.sub_id)),
        DataCell(Text(data.start)),
        DataCell(Text(data.end))
      ]));
    }
    return DataTable(columns: [
      DataColumn(
          label: Text('Order Id',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Sub-Order Id',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Start Time',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Finish Time',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
    ], rows: data_row);
  }

  Widget _buildResource(List<OrderResourceData> resource_list) {
    List<DataRow> data_row = new List<DataRow>();
    for (int i = 0; i < resource_list.length; i++) {
      OrderResourceData data = resource_list[i];
      data_row.add(DataRow(cells: [
        DataCell(Text(data.id)),
        DataCell(Text(data.sub_id)),
        DataCell(Text(data.resource_count)),
        DataCell(Text(data.time_count))
      ]));
    }
    return DataTable(columns: [
      DataColumn(
          label: Text('Order Id',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Sub-Order Id',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Resource Used(varieties)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Time Used(hours)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
    ], rows: data_row);
  }
}

void mockOrderTableConfig() {
  String response_order_info =
      '{"schedule":[{"id":"1","sub_id":"1","start":"2018-1-1 7:00","end":"2018-1-1 9:00"},{"id":"1","sub_id":"2","start":"2018-1-1 9:00","end":"2018-1-1 11:00"},{"id":"1","sub_id":"3","start":"2018-1-1 11:00","end":"2018-1-1 13:00"},{"id":"2","sub_id":"4","start":"2018-1-1 17:00","end":"2018-1-1 19:00"},{"id":"2","sub_id":"5","start":"2018-1-1 19:00","end":"2018-1-1 21:00"},{"id":"3","sub_id":"6","start":"2018-1-1 21:00","end":"2018-1-1 22:00"}],"resource":[{"id":"1","sub_id":"1","resource_count":2,"time_count":2},{"id":"1","sub_id":"2","resource_count":2,"time_count":2},{"id":"1","sub_id":"3","resource_count":2,"time_count":2},{"id":"2","sub_id":"4","resource_count":2,"time_count":2},{"id":"2","sub_id":"5","resource_count":2,"time_count":2},{"id":"3","sub_id":"6","resource_count":2,"time_count":1}]}';
  when(client.get('localhost:8080/order/info'))
      .thenAnswer((_) async => http.Response(response_order_info, 200));
}
