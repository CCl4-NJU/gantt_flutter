import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';
import 'dart:math';

import 'models.dart';

class GranttChartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new GranttChartScreenState();
  }
}

class GranttChartScreenState extends State<GranttChartScreen>
    with TickerProviderStateMixin {
  AnimationController animationController;

  DateTime fromDate = DateTime(2018, 1, 1);
  DateTime toDate = DateTime(2018, 1, 2);

  List<Product> usersInChart;
  List<Resource> projectsInChart;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: Duration(microseconds: 2000), vsync: this);
    animationController.forward();

    projectsInChart = projects;
    usersInChart = users;
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text('GANTT CHART'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: GanttChart(
                animationController: animationController,
                fromDate: fromDate,
                toDate: toDate,
                data: projectsInChart,
                usersInChart: usersInChart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GanttChart extends StatelessWidget {
  final AnimationController animationController;
  final DateTime fromDate;
  final DateTime toDate;
  final List<Resource> data;
  final List<Product> usersInChart;

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
        'NAME',
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
          tempDate.month.toString() +
              '/' +
              tempDate.year.toString() +
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

  Widget buildChartForEachUser(
      List<Resource> userData, double chartViewWidth, Product user) {
    Color color = randomColorGenerator();
    var chartBars = buildChartBars(userData, chartViewWidth, color);
    return Container(
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
                                width: chartViewWidth / viewRangeToFitScreen,
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
    );
  }

  List<Widget> buildChartContent(double chartViewWidth) {
    List<Widget> chartContent = new List();

    usersInChart.forEach((user) {
      List<Resource> projectsOfUser = new List();

      projectsOfUser = projects
          .where((project) => project.productions.indexOf(user.id) != -1)
          .toList();

      if (projectsOfUser.length > 0) {
        chartContent
            .add(buildChartForEachUser(projectsOfUser, chartViewWidth, user));
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
        child: ListView(children: buildChartContent(chartViewWidth)),
        removeTop: true,
        context: context,
      ),
    );
  }
}

var users = [
  Product(id: 1, name: '产品1'),
  Product(id: 2, name: '产品2'),
  Product(id: 3, name: '产品3'),
  Product(id: 4, name: '产品4'),
  Product(id: 5, name: '产品5'),
];

//productions：一条生产线同一时段可以同时生产多个产品，只是示例刚好没有这种情况
//两个问题：1. 不能跨天显示 2. 时间必须为整点，否则会向下取整
var projects = [
  Resource(
      id: 1,
      name: 'Line 1',
      startTime: DateTime(2018, 1, 1, 7, 0),
      endTime: DateTime(2018, 1, 1, 9, 0),
      productions: [1]),
  Resource(
      id: 2,
      name: 'Line 1',
      startTime: DateTime(2018, 1, 1, 9, 0),
      endTime: DateTime(2018, 1, 1, 17, 0),
      productions: [2]),
  Resource(
      id: 3,
      name: 'Line 1',
      startTime: DateTime(2018, 1, 1, 18, 0),
      endTime: DateTime(2018, 1, 1, 21, 0),
      productions: [3]),
  Resource(
      id: 4,
      name: 'Line 1',
      startTime: DateTime(2018, 1, 1, 21, 0),
      endTime: DateTime(2018, 1, 1, 23, 0),
      productions: [4]),
  Resource(
      id: 5,
      name: 'Line 4',
      startTime: DateTime(2018, 1, 1, 9, 0),
      endTime: DateTime(2018, 1, 1, 11, 0),
      productions: [3]),
  Resource(
      id: 6,
      name: '李四',
      startTime: DateTime(2018, 1, 1, 7, 0),
      endTime: DateTime(2018, 1, 1, 9, 0),
      productions: [1]),
  Resource(
      id: 7,
      name: '李四',
      startTime: DateTime(2018, 1, 1, 9, 0),
      endTime: DateTime(2018, 1, 1, 17, 0),
      productions: [2]),
  Resource(
      id: 8,
      name: '李四',
      startTime: DateTime(2018, 1, 1, 21, 0),
      endTime: DateTime(2018, 1, 1, 23, 0),
      productions: [5]),
  Resource(
      id: 9,
      name: '小明',
      startTime: DateTime(2018, 1, 1, 9, 0),
      endTime: DateTime(2018, 1, 1, 11, 0),
      productions: [3]),
  Resource(
      id: 10,
      name: '小明',
      startTime: DateTime(2018, 1, 1, 18, 0),
      endTime: DateTime(2018, 1, 1, 19, 0),
      productions: [3]),
  Resource(
      id: 11,
      name: '张三',
      startTime: DateTime(2018, 1, 1, 19, 0),
      endTime: DateTime(2018, 1, 1, 21, 0),
      productions: [3]),
  Resource(
      id: 12,
      name: '张三',
      startTime: DateTime(2018, 1, 1, 21, 0),
      endTime: DateTime(2018, 1, 1, 23, 0),
      productions: [4]),
];
