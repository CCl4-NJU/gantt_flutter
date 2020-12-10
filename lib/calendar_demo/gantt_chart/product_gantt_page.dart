import 'package:flutter/material.dart';
import 'package:gantt_flutter/calendar_demo/http_data/gantt_data.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:gantt_flutter/models.dart';
import 'package:gantt_flutter/calendar_demo/responsive.dart';

class MockClient extends Mock implements http.Client {}

final client = MockClient();

String product_id;
Color color;

class ProductGanttPage extends StatefulWidget {
  final String product_id;
  final DateTime from_date;
  final Color gantt_color;

  ProductGanttPage(
      {Key key,
      @required this.product_id,
      @required this.from_date,
      @required this.gantt_color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ProductGranttScreenState();
  }
}

class ProductGranttScreenState extends State<ProductGanttPage>
    with TickerProviderStateMixin {
  AnimationController animationController;

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

    fromDate = widget.from_date;
    toDate = fromDate.add(new Duration(days: 1));

    resourcesInChart = new List<Resource>();
    productsInChart = new List<Product>();

    color = widget.gantt_color;

    mockProductGanttConfig();
    futureGantt = fetchProductData(client, fromDate, widget.product_id);
  }

  Widget buildAppBar() {
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

        futureGantt = fetchProductData(client, fromDate, widget.product_id);
      });
    }

    return AppBar(
      title: Text('Product Gantt',
          style: TextStyle(
              fontSize: AdaptiveTextSize().getadaptiveTextSize(context, 20.0))),
      actions: [
        RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () {
            datePicker();
          },
          child: Text("Change date",
              style: TextStyle(
                  fontSize:
                      AdaptiveTextSize().getadaptiveTextSize(context, 20.0))),
        )
      ],
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
            child: ProductGantt(
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
    return Scaffold(
      appBar: buildAppBar(),
      body: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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

  Widget buildChartForEachUser(BuildContext context, List<Resource> userData,
      double chartViewWidth, Product user) {
    // Color color = randomColorGenerator();
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
                                      style: TextStyle(
                                          fontSize: AdaptiveTextSize()
                                              .getadaptiveTextSize(
                                                  context, 16.0)),
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
        chartContent.add(buildChartForEachUser(
            context, projectsOfUser, chartViewWidth, user));
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

void mockProductGanttConfig() {
  String response_p1_2018_1_1 =
      '{"products":[{"id":"1","name":"product 1"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-7-0","endTime":"2018-1-1-9-0","productId":"1"},{"id":"2","name":"Li Si","startTime":"2018-1-1-7-0","endTime":"2018-1-1-9-0","productId":"1"}]}';
  String response_p1_2018_1_2 =
      '{"products":[{"id":"1","name":"product 1"}],"resources":[{"id":"1","name":"Line 2","startTime":"2018-1-2-7-0","endTime":"2018-1-2-9-0","productId":"1"},{"id":"2","name":"Zhao Liu","startTime":"2018-1-2-7-0","endTime":"2018-1-2-9-0","productId":"1"}]}';

  String response_p2_2018_1_1 =
      '{"products":[{"id":"2","name":"product 2"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-9-0","endTime":"2018-1-1-17-0","productId":"2"},{"id":"2","name":"Li Si","startTime":"2018-1-1-9-0","endTime":"2018-1-1-17-0","productId":"2"}]}';
  String response_p2_2018_1_2 =
      '{"products":[{"id":"2","name":"product 2"}],"resources":[{"id":"1","name":"Line 2","startTime":"2018-1-2-9-0","endTime":"2018-1-2-17-0","productId":"2"},{"id":"2","name":"Zhao Liu","startTime":"2018-1-2-9-0","endTime":"2018-1-2-17-0","productId":"2"}]}';

  String response_p3_2018_1_1 =
      '{"products":[{"id":"3","name":"product 3"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-18-0","endTime":"2018-1-1-21-0","productId":"3"},{"id":"2","name":"Line 4","startTime":"2018-1-1-9-0","endTime":"2018-1-1-11-0","productId":"3"},{"id":"3","name":"Xiao Ming","startTime":"2018-1-1-9-0","endTime":"2018-1-1-11-0","productId":"3"},{"id":"4","name":"Xiao Ming","startTime":"2018-1-1-18-0","endTime":"2018-1-1-19-0","productId":"3"},{"id":"5","name":"Zhang San","startTime":"2018-1-1-19-0","endTime":"2018-1-1-21-0","productId":"3"}]}';
  String response_p3_2018_1_2 =
      '{"products":[{"id":"3","name":"product 3"}],"resources":[{"id":"1","name":"Line 2","startTime":"2018-1-2-18-0","endTime":"2018-1-2-21-0","productId":"3"},{"id":"2","name":"Line 3","startTime":"2018-1-2-9-0","endTime":"2018-1-2-11-0","productId":"3"},{"id":"3","name":"Xiao Hong","startTime":"2018-1-2-9-0","endTime":"2018-1-2-11-0","productId":"3"},{"id":"4","name":"Xiao Hong","startTime":"2018-1-2-18-0","endTime":"2018-1-2-19-0","productId":"3"},{"id":"5","name":"Wang Wu","startTime":"2018-1-2-19-0","endTime":"2018-1-2-21-0","productId":"3"}]}';

  String response_p4_2018_1_1 =
      '{"products":[{"id":"4","name":"product 4"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"4"},{"id":"2","name":"Zhang San","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"4"}]}';
  String response_p4_2018_1_2 =
      '{"products":[{"id":"4","name":"product 4"}],"resources":[{"id":"1","name":"Line 2","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"4"},{"id":"2","name":"Wang Wu","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"4"}]}';

  String response_p5_2018_1_1 =
      '{"products":[{"id":"5","name":"product 5"}],"resources":[{"id":"1","name":"Line 1","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"5"},{"id":"2","name":"Li Si","startTime":"2018-1-1-21-0","endTime":"2018-1-1-23-0","productId":"5"}]}';
  String response_p5_2018_1_2 =
      '{"products":[{"id":"5","name":"product 5"}],"resources":[{"id":"1","name":"Line 2","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"5"},{"id":"2","name":"Zhao Liu","startTime":"2018-1-2-21-0","endTime":"2018-1-2-23-0","productId":"5"}]}';

  when(client.get('localhost:8080/gantt/product/1/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_p1_2018_1_1, 200));
  when(client.get('localhost:8080/gantt/product/1/2018-1-2'))
      .thenAnswer((_) async => http.Response(response_p1_2018_1_2, 200));

  when(client.get('localhost:8080/gantt/product/2/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_p2_2018_1_1, 200));
  when(client.get('localhost:8080/gantt/product/2/2018-1-2'))
      .thenAnswer((_) async => http.Response(response_p2_2018_1_2, 200));

  when(client.get('localhost:8080/gantt/product/3/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_p3_2018_1_1, 200));
  when(client.get('localhost:8080/gantt/product/3/2018-1-2'))
      .thenAnswer((_) async => http.Response(response_p3_2018_1_2, 200));

  when(client.get('localhost:8080/gantt/product/4/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_p4_2018_1_1, 200));
  when(client.get('localhost:8080/gantt/product/4/2018-1-2'))
      .thenAnswer((_) async => http.Response(response_p4_2018_1_2, 200));

  when(client.get('localhost:8080/gantt/product/5/2018-1-1'))
      .thenAnswer((_) async => http.Response(response_p5_2018_1_1, 200));
  when(client.get('localhost:8080/gantt/product/5/2018-1-2'))
      .thenAnswer((_) async => http.Response(response_p5_2018_1_2, 200));
}
