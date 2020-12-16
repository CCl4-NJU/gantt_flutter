import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_model.dart';
import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_view.dart';
import 'package:gantt_flutter/calendar_demo/http_data/table_data.dart';
import 'package:gantt_flutter/calendar_demo/responsive.dart';

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class SubOrderTableDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SubOrderTableDemoPageState();
  }
}

class _SubOrderTableDemoPageState extends State<SubOrderTableDemoPage> {
  Future<SubOrderTablePageData> futureSubOrderTable;

  List<SubOrderScheduleTableData> _sub_order_schedule;
  List<SubOrderResourceTableData> _sub_order_resource;

  DateTime _selected_date;

  @override
  void initState() {
    super.initState();

    _sub_order_schedule = new List<SubOrderScheduleTableData>();
    _sub_order_resource = new List<SubOrderResourceTableData>();
    _selected_date = DateTime(2018, 1, 1);

    mockSubOrderTableConfig();
    futureSubOrderTable = fetchSubOrderTableData(client, _selected_date);
  }

  @override
  Widget build(BuildContext context) {
    datePicker() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selected_date,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
      );
      setState(() {
        _selected_date = picked;

        futureSubOrderTable = fetchSubOrderTableData(client, picked);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Sub-Order Info',
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 20.0))),
        actions: [
          RaisedButton(
            color: Colors.blue,
            textColor: Colors.white,
            onPressed: () {
              datePicker();
            },
            child: Icon(Icons.calendar_today_outlined,
                size: AdaptiveTextSize().getadaptiveTextSize(context, 20.0)),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder<SubOrderTablePageData>(
          future: futureSubOrderTable,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _sub_order_schedule.clear();
              _sub_order_resource.clear();

              _sub_order_schedule.addAll(snapshot.data.sub_order_schedule);

              _sub_order_resource.addAll(snapshot.data.sub_order_resource);

              return QuickSwitchView(
                  primary: QuickSwitchModel(
                      "Schedule", _buildSchedule(_sub_order_schedule)),
                  secondary: QuickSwitchModel(
                      "Resource", _buildResource(_sub_order_resource)));
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

  Widget _buildSchedule(List<SubOrderScheduleTableData> schedule_list) {
    List<DataRow> data_row = new List<DataRow>();
    for (int i = 0; i < schedule_list.length; i++) {
      SubOrderScheduleTableData data = schedule_list[i];
      data_row.add(DataRow(cells: [
        DataCell(Text(data.sub_id,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.resource_name,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.start,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.end,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0))))
      ]));
    }
    return DataTable(columns: [
      DataColumn(
          label: Text('Sub-Order Id',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Resource Name',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Start Time',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Finish Time',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
    ], rows: data_row);
  }

  Widget _buildResource(List<SubOrderResourceTableData> resource_list) {
    List<DataRow> data_row = new List<DataRow>();
    for (int i = 0; i < resource_list.length; i++) {
      SubOrderResourceTableData data = resource_list[i];
      data_row.add(DataRow(cells: [
        DataCell(Text(data.resource_name,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.start,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.end,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.sub_used,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0)))),
        DataCell(Text(data.used,
            style: TextStyle(
                fontSize:
                    AdaptiveTextSize().getadaptiveTextSize(context, 10.0))))
      ]));
    }
    return DataTable(columns: [
      DataColumn(
          label: Text('Resource Name',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Start Time',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Finish Time',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Used by Sub-Order',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Used by Order',
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 12.0),
                  fontWeight: FontWeight.bold))),
    ], rows: data_row);
  }
}

void mockSubOrderTableConfig() {
  String response_sub_order_info =
      '{"schedule":[{"sub_id":"1","resource_name":"Zhang San","start":"2018-1-1 7:00","end":"2018-1-1 9:00"},{"sub_id":"2","resource_name":"Zhang San","start":"2018-1-1 9:00","end":"2018-1-1 11:00"},{"sub_id":"3","resource_name":"Zhang San","start":"2018-1-1 11:00","end":"2018-1-1 13:00"},{"sub_id":"4","resource_name":"Li Si","start":"2018-1-1 17:00","end":"2018-1-1 19:00"},{"sub_id":"5","resource_name":"Li Si","start":"2018-1-1 19:00","end":"2018-1-1 21:00"},{"sub_id":"6","resource_name":"Li Si","start":"2018-1-1 21:00","end":"2018-1-1 22:00"}],"resource":[{"resource_name":"Zhang San","start":"2018-1-1 7:00","end":"2018-1-1 9:00","sub_used":"1","used":"1"},{"resource_name":"Zhang San","start":"2018-1-1 9:00","end":"2018-1-1 11:00","sub_used":"2","used":"1"},{"resource_name":"Zhang San","start":"2018-1-1 11:00","end":"2018-1-1 13:00","sub_used":"3","used":"1"},{"resource_name":"Li Si","start":"2018-1-1 17:00","end":"2018-1-1 19:00","sub_used":"4","used":"2"},{"resource_name":"Li Si","start":"2018-1-1 19:00","end":"2018-1-1 21:00","sub_used":"5","used":"2"},{"resource_name":"Li Si","start":"2018-1-1 21:00","end":"2018-1-1 22:00","sub_used":"6","used":"2"}]}';
  when(client.get('localhost:8080/suborder/info/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_sub_order_info, 200));
}
