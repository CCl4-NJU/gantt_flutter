import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:gantt_flutter/calendar_demo/http_data/progress_data.dart';
import 'package:gantt_flutter/models.dart';
import 'using_card_view.dart';
import 'package:gantt_flutter/calendar_demo/responsive.dart';

var progress_colors = [
  Colors.lightBlue,
  Colors.lime,
  Colors.orange,
  Colors.purple,
];

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class ProgressDemoPage extends StatefulWidget {
  @override
  ProgressDemoPageState createState() => ProgressDemoPageState();
}

class ProgressDemoPageState extends State<ProgressDemoPage> {
  Future<ProgressPageData> futureProgress;
  Size size;

  List<OrderData> _data_items;
  int _delivery_rate;
  DateTime _selected_date;

  @override
  void initState() {
    super.initState();

    _selected_date = DateTime(2017, 10, 1);
    _delivery_rate = 0;
    _data_items = <OrderData>[];

    mockProgressConfig();
    futureProgress = fetchProgressData(client, _selected_date);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    datePicker() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selected_date,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
      );
      setState(() {
        _selected_date = picked;

        futureProgress = fetchProgressData(client, _selected_date);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Progress',
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
      body: Center(
        child: FutureBuilder<ProgressPageData>(
          future: futureProgress,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _data_items.clear();
              _data_items.addAll(snapshot.data.orders
                  .map((item) => OrderData(
                      item.id,
                      item.crafts
                          .map((craft) =>
                              ProgressData(craft.name, craft.percent))
                          .toList(),
                      item.delay))
                  .toList());

              //添加一个空数据，因为有个小bug不知道如何解决
              _data_items.add(OrderData('', new List<ProgressData>(), false));

              _delivery_rate = snapshot.data.rate;
              return _buildCharts(context);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildCharts(BuildContext context) {
    return UsingCardView(
      card: ConstrainedBox(
        constraints:
            BoxConstraints.expand(width: size.width, height: size.height * 0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _buildHeader(),
        ),
      ),
      view: Container(
        child: ListView.builder(
          padding: EdgeInsets.all(size.height / 40.0),
          itemCount: _data_items.length,
          itemBuilder: (BuildContext context, int index) {
            OrderData data = _data_items[index];
            List<Widget> progress_items = [];
            Widget content;
            int len = data.crafts.length;
            for (int i = 0; i < len; i++) {
              double percent = data.crafts[i].percent;
              String center_str = data.crafts[i].name +
                  ': ' +
                  (data.crafts[i].percent * 100).toString() +
                  '%';
              progress_items.add(new LinearPercentIndicator(
                width: (size.width * 0.8) / len,
                lineHeight: size.height / 30.0,
                animation: true,
                animationDuration: 500,
                percent: percent,
                center: Text(center_str,
                    style: TextStyle(
                        fontSize: AdaptiveTextSize()
                            .getadaptiveTextSize(context, 12.0))),
                progressColor: data.delay
                    ? Colors.red
                    : (percent >= 1
                        ? Colors.green
                        : progress_colors[i % progress_colors.length]),
                linearStrokeCap: LinearStrokeCap.roundAll,
              ));
            }
            content = Row(
              children: progress_items,
            );

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
                      index == _data_items.length - 1
                          ? ''
                          : 'Order No.' + data.id,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
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
                      child: content,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Stack(
        children: <Widget>[
          _buildCard(),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height / 30.0),
          child: Container(
            height: size.height / 2.0,
            width: size.height / 2.0,
            decoration: BoxDecoration(),
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.album),
                    title: Text('Order On-time Delivery Rate'),
                    subtitle: Text(
                      'Before ' +
                          DateFormat('yyyy-MM-dd').format(_selected_date),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AdaptiveTextSize()
                              .getadaptiveTextSize(context, 14.0)),
                    ),
                  ),
                  _buildSum(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildSum(BuildContext context) {
    return CircularPercentIndicator(
      radius: size.height / 4.0,
      animation: true,
      animationDuration: 1200,
      lineWidth: (size.width / 66.7),
      percent: _delivery_rate / 100.0,
      center: new Text(
        _delivery_rate.toString() + '%',
        style: new TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 20.0)),
      ),
      progressColor: _delivery_rate < 20
          ? Colors.red
          : progress_colors[4 - (_delivery_rate ~/ 20)],
    );
  }
}

void mockProgressConfig() {
  String response_2017_10_01 =
      '{"orders":[{"id":"418575","delay":false},{"id":"418477","delay":true},{"id":"418480","delay":false},{"id":"418520","delay":false},{"id":"418555","delay":false},{"id":"418577","delay":false}],"crafts":[{"id":"418575","name":"Assemble","percent":0.6},{"id":"418477","name":"Assemble","percent":0.23},{"id":"418477","name":"Test","percent":0.18},{"id":"418480","name":"Assemble","percent":0.98},{"id":"418480","name":"Combine","percent":0.68},{"id":"418480","name":"Test","percent":0.08},{"id":"418520","name":"Assemble","percent":0.63},{"id":"418555","name":"Assemble","percent":0.25},{"id":"418555","name":"Test","percent":0.0},{"id":"418577","name":"Assemble","percent":0.78}],"rate":83}';
  String response_2017_10_02 =
      '{"orders":[{"id":"418575","delay":false},{"id":"418477","delay":true},{"id":"418480","delay":false},{"id":"418520","delay":false},{"id":"418555","delay":false},{"id":"418577","delay":false},{"id":"518034","delay":false},{"id":"523002","delay":false},{"id":"523864","delay":false}],"crafts":[{"id":"418575","name":"Assemble","percent":1.0},{"id":"418477","name":"Assemble","percent":0.83},{"id":"418477","name":"Test","percent":0.78},{"id":"418480","name":"Assemble","percent":1.0},{"id":"418480","name":"Combine","percent":1.0},{"id":"418480","name":"Test","percent":0.9},{"id":"418520","name":"Assemble","percent":1.0},{"id":"418555","name":"Assemble","percent":0.75},{"id":"418555","name":"Test","percent":0.7},{"id":"418577","name":"Assemble","percent":1.0},{"id":"518034","name":"Assemble","percent":0.55},{"id":"518034","name":"Test","percent":0.4},{"id":"523002","name":"Assemble","percent":0.43},{"id":"523864","name":"Assemble","percent":0.3},{"id":"523864","name":"Recheck","percent":0.1},{"id":"523864","name":"Transport","percent":0.06},{"id":"523864","name":"Test","percent":0.0}],"rate":88}';
  when(client.get('localhost:8080/progress/2017-10-1'))
      .thenAnswer((_) async => http.Response(response_2017_10_01, 200));
  when(client.get('localhost:8080/progress/2017-10-2'))
      .thenAnswer((_) async => http.Response(response_2017_10_02, 200));
}
