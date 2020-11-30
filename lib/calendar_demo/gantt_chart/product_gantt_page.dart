import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';
import 'dart:math';

import 'models.dart';

class ProductGanttPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ProductGranttScreenState();
  }
}

class ProductGranttScreenState extends State<ProductGanttPage>
    with TickerProviderStateMixin {
  AnimationController animationController;

  //设置时间
  DateTime fromDate;
  DateTime toDate;

  List<Product> usersInChart;
  List<Resource> projectsInChart;

  int _mock_index = 0;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: Duration(microseconds: 2000), vsync: this);
    animationController.forward();

    fromDate = DateTime(2018, 1, 1);
    toDate = DateTime(2018, 1, 2);

    projectsInChart = projects;
    usersInChart = users;
  }

  Widget buildAppBar() {
    return AppBar(
      title: Text('Product Gantt'),
    );
  }

  Widget buildGantt() {
    return new Expanded(
      child: ProductGantt(
        animationController: animationController,
        fromDate: fromDate,
        toDate: toDate,
        data: projectsInChart,
        usersInChart: usersInChart,
      ),
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

        _mock_index = 1 - _mock_index;
        projectsInChart = proj_arr[_mock_index];
      });

      print(picked);
      //TODO:Change gantt data
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
                    child: Text("View product gantt in another date..."),
                  ),
                ],
              ),
            ),
            buildGantt(),
          ],
        ),
      ),
    );
  }
}

class ProductGantt extends StatelessWidget {
  final AnimationController animationController;
  DateTime fromDate;
  DateTime toDate;
  List<Resource> data;
  List<Product> usersInChart;

  int viewRange;
  int viewRangeToFitScreen = 6;
  Animation<double> width;

  ProductGantt({
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

  List<Widget> buildChartContent(double chartViewWidth, BuildContext context) {
    List<Widget> chartContent = new List();

    usersInChart.forEach((user) {
      List<Resource> projectsOfUser = new List();

      projectsOfUser = data
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
        child: ListView(children: buildChartContent(chartViewWidth, context)),
        removeTop: true,
        context: context,
      ),
    );
  }
}

var users = [
  Product(id: 3, name: '产品3'),
];

var projects = [
  Resource(
      id: 1,
      name: 'Line 1',
      startTime: DateTime(2018, 1, 1, 18, 0),
      endTime: DateTime(2018, 1, 1, 21, 0),
      productions: [3]),
  Resource(
      id: 2,
      name: 'Line 4',
      startTime: DateTime(2018, 1, 1, 9, 0),
      endTime: DateTime(2018, 1, 1, 11, 0),
      productions: [3]),
  Resource(
      id: 3,
      name: '小明',
      startTime: DateTime(2018, 1, 1, 9, 0),
      endTime: DateTime(2018, 1, 1, 11, 0),
      productions: [3]),
  Resource(
      id: 4,
      name: '小明',
      startTime: DateTime(2018, 1, 1, 18, 0),
      endTime: DateTime(2018, 1, 1, 19, 0),
      productions: [3]),
  Resource(
      id: 5,
      name: '张三',
      startTime: DateTime(2018, 1, 1, 19, 0),
      endTime: DateTime(2018, 1, 1, 21, 0),
      productions: [3]),
];

var projects2 = [
  Resource(
      id: 1,
      name: 'Line 2',
      startTime: DateTime(2018, 1, 2, 12, 0),
      endTime: DateTime(2018, 1, 2, 15, 0),
      productions: [3]),
  Resource(
      id: 2,
      name: 'Line 4',
      startTime: DateTime(2018, 1, 2, 3, 0),
      endTime: DateTime(2018, 1, 2, 5, 0),
      productions: [3]),
  Resource(
      id: 3,
      name: '小胖',
      startTime: DateTime(2018, 1, 2, 3, 0),
      endTime: DateTime(2018, 1, 2, 5, 0),
      productions: [3]),
  Resource(
      id: 4,
      name: '小胖',
      startTime: DateTime(2018, 1, 2, 12, 0),
      endTime: DateTime(2018, 1, 2, 13, 0),
      productions: [3]),
  Resource(
      id: 5,
      name: '三仔',
      startTime: DateTime(2018, 1, 2, 13, 0),
      endTime: DateTime(2018, 1, 2, 15, 0),
      productions: [3]),
];

var proj_arr = [projects, projects2];
