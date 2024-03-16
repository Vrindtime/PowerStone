import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/services/payment/payment.dart';

class MonthlyFlowChart extends StatefulWidget {
  const MonthlyFlowChart({super.key});

  @override
  State<MonthlyFlowChart> createState() => _MonthlyFlowChartState();
}

class _MonthlyFlowChartState extends State<MonthlyFlowChart> {
  PaymentService monthlyService =
      PaymentService(); // Create an instance of PaymentService
  Map<String, int>? monthlyEarnings; // Declare monthlyEarnings variable

  late List<FlSpot> spots = [];
  bool isLoading = true;
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
    mainData(); // Fetch monthly earnings data when the widget initializes
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

  Future<List<FlSpot>> getMonthEarningsAsSpots() async {
    final now = DateTime.now();
    PaymentService service = PaymentService();

    for (int i = 0; i < 12; i++) { //11 cause i starts from 0 and no.of months in a year =12
      try {
        final monthSnapshot = await service.getMonthEarningPerMonth(
            now.year.toString(), months[i]);
        // Access the data appropriately based on its type:
        final Map<String, dynamic>? data =
            monthSnapshot.data() as Map<String, dynamic>?; //type changing
        final monthEarning = data?['value'] ?? 0;
        double normalizedEarning = monthEarning.toDouble() / 20000; 
        spots.add(FlSpot(i.toDouble(), normalizedEarning));
      } catch (error) {
        print("Error fetching data: $error");
      }
      setState(() {}); // Update the widget after fetching data
    }

    return spots;
  }

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
              chartWidget(),
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
        text = '<5K';
        break;
      case 1:
        text = '20K';
        break;
      case 2:
        text = '40K';
        break;
      case 3:
        text = '60K';
        break;
      case 4:
        text = '80K';
        break;
      case 5:
        text = '100K';
        break;
      case 6:
        text = '120K';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Future mainData() async {
    spots = await getMonthEarningsAsSpots();
    setState(() {
      isLoading = !isLoading;
    });
  }

  LineChartData chartWidget(){
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
          spots: spots,
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
