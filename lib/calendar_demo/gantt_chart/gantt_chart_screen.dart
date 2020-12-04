import 'package:flutter/material.dart';
import 'product_gantt_page.dart';
import 'package:gantt_flutter/calendar_demo/http_data/gantt_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'models.dart';

class MockClient extends Mock implements http.Client {}

final client = MockClient();

class GranttChartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GranttChartScreenState();
  }
}

class GranttChartScreenState extends State<GranttChartScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;
  Widget ganttWidget;

  Future<GanttPageData> futureGantt;

  //设置时间
  DateTime fromDate;
  DateTime toDate;

  List<Product> productsInChart;
  List<Resource> resourcesInChart;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: Duration(microseconds: 2000), vsync: this);
    animationController.forward();

    fromDate = DateTime(2018, 1, 1);
    toDate = DateTime(2018, 1, 2);

    productsInChart = new List<Product>();
    resourcesInChart = new List<Resource>();

    mockResourceGanttConfig();
    futureGantt = fetchResourceData(client, fromDate);

    ganttWidget = buildGantt();
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text('Resource Gantt'),
    );
  }

  Widget buildGantt() {
    return FutureBuilder<GanttPageData>(
      future: futureGantt,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          productsInChart.clear();
          productsInChart.addAll(snapshot.data.products
              .map((p) => Product(id: p.id, name: p.name))
              .toList());

          resourcesInChart.clear();
          resourcesInChart.addAll(snapshot.data.resources
              .map((r) => Resource(
                  id: r.id,
                  name: r.name,
                  startTime: r.startTime,
                  endTime: r.endTime,
                  productions: r.productions))
              .toList());

          return Expanded(
            child: GanttChart(
              animationController: animationController,
              fromDate: fromDate,
              toDate: toDate,
              data: resourcesInChart,
              usersInChart: productsInChart,
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    datePicker() async {
      DateTime picked = await showDatePicker(
        context: context,
        initialDate: fromDate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
      );
      setState(() {
        fromDate = picked;
        toDate = fromDate.add(new Duration(days: 1));

        futureGantt = fetchResourceData(client, picked);

        ganttWidget = buildGantt();
      });
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    onPressed: () {
                      datePicker();
                    },
                    child: Text("View resource gantt in another date..."),
                  ),
                ],
              ),
            ),
            ganttWidget,
          ],
        ),
      ),
    );
  }
}

class GanttChart extends StatelessWidget {
  final AnimationController animationController;
  DateTime fromDate;
  DateTime toDate;
  List<Resource> data;
  List<Product> usersInChart;

  int viewRange;
  int viewRangeToFitScreen = 6;
  Animation<double> width;

  GanttChart({
    this.animationController,
    this.fromDate,
    this.toDate,
    this.data,
    this.usersInChart,
  }) {
    // viewRange = calculateNumberOfMonthsBetween(fromDate, toDate);
    viewRange = calculateNumberOfHoursBetween(fromDate, toDate);
  }

  Color randomColorGenerator() {
    var r = new Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 0.75);
  }

  int calculateNumberOfMonthsBetween(DateTime from, DateTime to) {
    return to.month - from.month + 12 * (to.year - from.year) + 1;
  }

  int calculateNumberOfHoursBetween(DateTime from, DateTime to) {
    // print(from.difference(to).inHours);
    return to.difference(from).inHours;
  }

  int calculateDistanceToLeftBorder(DateTime projectStartedAt) {
    if (projectStartedAt.compareTo(fromDate) <= 0) {
      return 0;
    } else
      // return calculateNumberOfMonthsBetween(fromDate, projectStartedAt) - 1;
      return calculateNumberOfHoursBetween(fromDate, projectStartedAt);
  }

  int calculateRemainingWidth(
      DateTime projectStartedAt, DateTime projectEndedAt) {
    int projectLength =
        // calculateNumberOfMonthsBetween(projectStartedAt, projectEndedAt);
        calculateNumberOfHoursBetween(projectStartedAt, projectEndedAt);
    if (projectStartedAt.compareTo(fromDate) >= 0 &&
        projectStartedAt.compareTo(toDate) <= 0) {
      if (projectLength <= viewRange)
        return projectLength;
      else
        return viewRange -
            // calculateNumberOfMonthsBetween(fromDate, projectStartedAt);
            calculateNumberOfHoursBetween(fromDate, projectStartedAt);
    } else if (projectStartedAt.isBefore(fromDate) &&
        projectEndedAt.isBefore(fromDate)) {
      return 0;
    } else if (projectStartedAt.isBefore(fromDate) &&
        projectEndedAt.isBefore(toDate)) {
      return projectLength -
          // calculateNumberOfMonthsBetween(projectStartedAt, fromDate);
          calculateNumberOfHoursBetween(projectStartedAt, fromDate);
    } else if (projectStartedAt.isBefore(fromDate) &&
        projectEndedAt.isAfter(toDate)) {
      return viewRange;
    }
    return 0;
  }

  List<Widget> buildChartBars(
      List<Resource> data, double chartViewWidth, Color color) {
    List<Widget> chartBars = new List();

    for (int i = 0; i < data.length; i++) {
      var remainingWidth =
          calculateRemainingWidth(data[i].startTime, data[i].endTime);

      if (remainingWidth > 0) {
        chartBars.add(Container(
          decoration: BoxDecoration(
              color: color.withAlpha(100),
              borderRadius: BorderRadius.circular(10.0)),
          height: 25.0,
          width: remainingWidth * chartViewWidth / viewRangeToFitScreen,
          margin: EdgeInsets.only(
              left: calculateDistanceToLeftBorder(data[i].startTime) *
                  chartViewWidth /
                  viewRangeToFitScreen,
              top: i == 0 ? 4.0 : 2.0,
              bottom: i == data.length - 1 ? 4.0 : 2.0),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              data[i].name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.0),
            ),
          ),
        ));
      }
    }

    return chartBars;
  }

  //渲染头部时间信息
  Widget buildHeader(double chartViewWidth, Color color) {
    List<Widget> headerItems = new List();

    DateTime tempDate = fromDate;

    headerItems.add(Container(
      width: chartViewWidth / viewRangeToFitScreen,
      child: new Text(
        'PRODUCT',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.0,
        ),
      ),
    ));

    for (int i = 0; i < viewRange; i++) {
      headerItems.add(Container(
        width: chartViewWidth / viewRangeToFitScreen,
        child: new Text(
          tempDate.year.toString() +
              '/' +
              tempDate.month.toString() +
              '/' +
              tempDate.day.toString() +
              ' ' +
              tempDate.hour.toString() +
              ':' +
              tempDate.minute.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.0,
          ),
        ),
      ));
      // tempDate = Utils.nextMonth(tempDate);
      tempDate = tempDate.add(new Duration(hours: 1));
    }

    return Container(
      height: 25.0,
      color: color.withAlpha(100),
      child: Row(
        children: headerItems,
      ),
    );
  }

  //渲染时间段边界
  Widget buildGrid(double chartViewWidth) {
    List<Widget> gridColumns = new List();

    for (int i = 0; i <= viewRange; i++) {
      gridColumns.add(Container(
        decoration: BoxDecoration(
            border: Border(
                right:
                    BorderSide(color: Colors.grey.withAlpha(100), width: 1.0))),
        width: chartViewWidth / viewRangeToFitScreen,
        //height: 300.0,
      ));
    }

    return Row(
      children: gridColumns,
    );
  }

  Widget buildChartForEachUser(List<Resource> userData, double chartViewWidth,
      Product user, BuildContext context) {
    Color color = randomColorGenerator();
    var chartBars = buildChartBars(userData, chartViewWidth, color);
    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProductGanttPage(
                      product_id: user.id.toString(),
                      from_date: fromDate,
                    )),
          );
        },
        child: new Container(
          height: chartBars.length * 29.0 + 25.0 + 4.0,
          child: ListView(
            physics: new ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Stack(fit: StackFit.loose, children: <Widget>[
                buildGrid(chartViewWidth),
                buildHeader(chartViewWidth, color),
                Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(
                              children: <Widget>[
                                Container(
                                    width:
                                        chartViewWidth / viewRangeToFitScreen,
                                    height: chartBars.length * 29.0 + 4.0,
                                    color: color.withAlpha(100),
                                    child: Center(
                                      child: new RotatedBox(
                                        quarterTurns:
                                            chartBars.length * 29.0 + 4.0 > 50
                                                ? 0
                                                : 0,
                                        child: new Text(
                                          user.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: chartBars,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ]),
            ],
          ),
        ));
  }

  List<Widget> buildChartContent(double chartViewWidth, BuildContext context) {
    List<Widget> chartContent = new List();

    usersInChart.forEach((user) {
      List<Resource> projectsOfUser = new List();

      //关键代码：tmd作者不小心把这里写死了...
      projectsOfUser = data
          .where((project) => project.productions.indexOf(user.id) != -1)
          .toList();

      if (projectsOfUser.length > 0) {
        chartContent.add(buildChartForEachUser(
            projectsOfUser, chartViewWidth, user, context));
      }
    });

    return chartContent;
  }

  @override
  Widget build(BuildContext context) {
    var chartViewWidth = MediaQuery.of(context).size.width;
    var screenOrientation = MediaQuery.of(context).orientation;

    screenOrientation == Orientation.landscape
        ? viewRangeToFitScreen = 12
        : viewRangeToFitScreen = 6;

    return Container(
      child: MediaQuery.removePadding(
        child: ListView(children: buildChartContent(chartViewWidth, context)),
        removeTop: true,
        context: context,
      ),
    );
  }
}

//productions：一条生产线同一时段可以同时生产多个产品，只是示例刚好没有这种情况
//两个问题：1. 不能跨天显示 2. 时间必须为整点，否则会向下取整
void mockResourceGanttConfig() {
  String response_2018_1_1 =
      '{"products":[{"id":"1","name":"product 1"},{"id":"2","name":"product 2"},{"id":"3","name":"product 3"},{"id":"4","name":"product 4"},{"id":"5","name":"product 5"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-7-0","endTime":"2018-1-1-9-0","productId":"1"},{"id":"2","name":"Line 1","startTime":"2018-1-1-9-0","endTime":"2018-1-1-17-0","productId":"2"},{"id":"3","name":"Line 1","startTime":"2018-1-1-18-0","endTime":"2018-1-1-21-0","productId":"3"},{"id":"4","name":"Line 1","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"4"},{"id":"5","name":"Line 4","startTime":"2018-1-1-9-0","endTime":"2018-1-1-11-0","productId":"3"},{"id":"6","name":"Li Si","startTime":"2018-1-1-7-0","endTime":"2018-1-1-9-0","productId":"1"},{"id":"7","name":"Li Si","startTime":"2018-1-1-9-0","endTime":"2018-1-1-17-0","productId":"2"},{"id":"8","name":"Li Si","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"5"},{"id":"9","name":"Xiao Ming","startTime":"2018-1-1-9-0","endTime":"2018-1-1-11-0","productId":"3"},{"id":"10","name":"Xiao Ming","startTime":"2018-1-1-18-0","endTime":"2018-1-1-19-0","productId":"3"},{"id":"11","name":"Zhang San","startTime":"2018-1-1-19-0","endTime":"2018-1-1-21-0","productId":"3"},{"id":"12","name":"Line 1","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"4"},{"id":"13","name":"Line 1","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"5"}]}';
  String response_2018_1_2 =
      '{"products":[{"id":"1","name":"product 1"},{"id":"2","name":"product 2"},{"id":"3","name":"product 3"},{"id":"4","name":"product 4"},{"id":"5","name":"product 5"}],"resources":[{"id":"1","name":"Line 2","startTime":"2018-1-2-7-0","endTime":"2018-1-2-9-0","productId":"1"},{"id":"2","name":"Line 2","startTime":"2018-1-2-9-0","endTime":"2018-1-2-17-0","productId":"2"},{"id":"3","name":"Line 2","startTime":"2018-1-2-18-0","endTime":"2018-1-2-21-0","productId":"3"},{"id":"4","name":"Line 2","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"4"},{"id":"5","name":"Line 3","startTime":"2018-1-2-9-0","endTime":"2018-1-2-11-0","productId":"3"},{"id":"6","name":"Zhao Liu","startTime":"2018-1-2-7-0","endTime":"2018-1-2-9-0","productId":"1"},{"id":"7","name":"Zhao Liu","startTime":"2018-1-2-9-0","endTime":"2018-1-2-17-0","productId":"2"},{"id":"8","name":"Zhao Liu","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"5"},{"id":"9","name":"Xiao Hong","startTime":"2018-1-2-9-0","endTime":"2018-1-2-11-0","productId":"3"},{"id":"10","name":"Xiao Hong","startTime":"2018-1-2-18-0","endTime":"2018-1-2-19-0","productId":"3"},{"id":"11","name":"Wang Wu","startTime":"2018-1-2-19-0","endTime":"2018-1-2-21-0","productId":"3"},{"id":"12","name":"Line 2","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"4"},{"id":"13","name":"Line 2","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"5"}]}';
  when(client.get('localhost:8080/gantt/resource/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_2018_1_1, 200));
  when(client.get('localhost:8080/gantt/resource/2018-1-2'))
      .thenAnswer((_) async => http.Response(response_2018_1_2, 200));
}
