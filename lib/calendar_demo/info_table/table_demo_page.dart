import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_model.dart';
import 'package:gantt_flutter/calendar_demo/info_table/quick_switch_view.dart';
import 'package:flutter/material.dart';

import 'package:gantt_flutter/models.dart';

class TableDemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TableDemoPageState();
  }
}

class _TableDemoPageState extends State<TableDemoPage> {
  List<ResourceData> _human_resources;
  List<ResourceData> _device_resources;

  @override
  void initState() {
    _human_resources = new List<ResourceData>();
    _device_resources = new List<ResourceData>();

    _human_resources.addAll([
      ResourceData('1', 'Tong Xiaoling', '5', 'day'),
      ResourceData('2', 'Wang Xiaohu', '4', 'night'),
    ]);

    _device_resources.addAll([
      ResourceData('1', 'Line 1', '2', 'day & night'),
      ResourceData('2', 'Line 4', '3', 'day & night'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Resource Info'),
          backgroundColor: Theme.of(context).primaryColor),
      body: Container(
        alignment: Alignment.center,
        child: QuickSwitchView(
          primary: QuickSwitchModel("Human", _buildTable(_human_resources)),
          secondary: QuickSwitchModel("Device", _buildTable(_device_resources)),
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
      ),
    );
  }

  Widget _buildList() {
    return Center(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 8.0)
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '#Item $index',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    height: 1.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blueGrey, Colors.transparent])),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Text(
                      'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source.',
                      style: TextStyle(color: Colors.black87, fontSize: 11.0),
                      maxLines: 3,
                      textAlign: TextAlign.justify,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHome() {
    return ListView(children: <Widget>[
      Center(
        child: DataTable(
          columns: [
            DataColumn(
                label: Text('Resource Name',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Resource Number',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Resource Drift',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ],
          rows: [],
        ),
      )
    ]);
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
    return DataTable(columns: [
      DataColumn(
          label: Text('Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Shift',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
    ], rows: data_row);
  }
}
