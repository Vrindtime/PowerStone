import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/services/payment/payment.dart';

class MonthlyFlowChart extends StatefulWidget {
  const MonthlyFlowChart({super.key});

  @override
  State<MonthlyFlowChart> createState() => _MonthlyFlowChartState();
}

class _MonthlyFlowChartState extends State<MonthlyFlowChart> {
  PaymentService monthlyService = PaymentService(); // Create an instance of PaymentService
  Map<String, int>? monthlyEarnings; // Declare monthlyEarnings variable

  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    super.initState();
    fetchMonthlyEarnings(); // Fetch monthly earnings data when the widget initializes
  }

  // Method to fetch monthly earnings data
  void fetchMonthlyEarnings() async {
    print('DEBUG:GOT ITNO FETCH MONTHLY ()');
    monthlyEarnings = await monthlyService.getMonthlyEarnings();
    print('DEBUG Monthly Earning in fl_chart.dart: $monthlyEarnings');
    setState(() {}); // Update the widget after fetching data
  }

  Map<String, int> normalizeMonthlyEarnings(Map<String, int> fetchedEarnings) {
    // Define the range of the graph
    double graphMinX = 0;
    double graphMaxX = 5;
    double graphMinY = 0;
    double graphMaxY = 11;

    // Determine the maximum earnings value
    int maxValue = fetchedEarnings.values
        .reduce((value1, value2) => value1 > value2 ? value1 : value2);

    // Normalize each monthly earnings value
    Map<String, int> normalizedEarnings = {};
    fetchedEarnings.forEach((month, earnings) {
      // Scale the earnings value to fit within the graph range
      double normalizedX = months.indexOf(month) *
          (graphMaxX / 11); // Assuming 12 months in a year
      double normalizedY = earnings * (graphMaxY / maxValue);
      normalizedEarnings[month] = normalizedY.toInt();
    });

    return normalizedEarnings;
  }

  List<Color> gradientColors = [
    const Color.fromRGBO(39, 221, 127, 1),
    const Color.fromARGB(255, 9, 145, 75),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.28,
      width: double.infinity,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
              left: 1,
              top: 15,
              bottom: 2,
            ),
            child: LineChart(
              mainData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('JAN', style: style);
        break;
      case 1:
        text = const Text('FEB', style: style);
        break;
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 3:
        text = const Text('APR', style: style);
        break;
      case 4:
        text = const Text('MAY', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 6:
        text = const Text('JUL', style: style);
        break;
      case 7:
        text = const Text('AUG', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      case 9:
        text = const Text('OCT', style: style);
        break;
      case 10:
        text = const Text('NOV', style: style);
        break;
      case 11:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '5k';
        break;
      case 1:
        text = '10K';
        break;
      case 2:
        text = '20K';
        break;
      case 3:
        text = '30K';
        break;
      case 4:
        text = '40K';
        break;
      case 5:
        text = '50K';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainData() {
    List<FlSpot> spots = [];
    if (monthlyEarnings != null && monthlyEarnings!.isNotEmpty) {
      Map<String, int> normalizedEarnings =
          normalizeMonthlyEarnings(monthlyEarnings!);
      normalizedEarnings.forEach((month, earnings) {
        int monthIndex = months.indexOf(month) + 1;
        spots.add(FlSpot(monthIndex.toDouble(), earnings.toDouble()));
      });
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: .5,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: .5,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets, //months
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets, //price
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d).withOpacity(0.2)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            //max 5 , min 0
            FlSpot(0, 5.00), // JAN
            FlSpot(1, 4.44), // FEB
            FlSpot(2, 3.44), // MAR
            FlSpot(3, 4.44), // APR
            FlSpot(4, 5.44), // MAY
            FlSpot(5, 4.44), // JUN
            FlSpot(6, 4.44), // JUL
            FlSpot(7, 2.44), // AUG
            FlSpot(8, 2.44), // SEP
            FlSpot(9, 3.44), // OCT
            FlSpot(10, 1.44), // NOV
            FlSpot(11, 3.44), // DEC
          ],
          // spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.4))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
