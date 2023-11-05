import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final internetSpeedTest = FlutterInternetSpeedTest();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  String _unitText = 'Mbps';
  int _downloadCompletionTime = 0;
  int _uploadCompletionTime = 0;
  String? _ip;
  String? _asn;
  String? _isp;
  bool _isServerSelectionInProgress = false;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    setState(() {
      _testInProgress = false;
      _downloadRate = 0;
      _uploadRate = 0;
      _downloadProgress = '0';
      _uploadProgress = '0';
      _unitText = 'Mbps';
      _downloadCompletionTime = 0;
      _uploadCompletionTime = 0;
      _ip = null;
      _asn = null;
      _isp = null;
    });
  }

  void startTesting() async {
    setState(() => _testInProgress = true);
    await internetSpeedTest.startTesting(
      onProgress: (double percent, TestResult data) {
        setState(() {
          _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
          if (data.type == TestType.download) {
            _downloadRate = data.transferRate;
            _downloadProgress = percent.toStringAsFixed(2);
          } else {
            _uploadRate = data.transferRate;
            _uploadProgress = percent.toStringAsFixed(2);
          }
        });
      },
      onDownloadComplete: (TestResult data) {
        setState(() {
          _downloadRate = data.transferRate;
          _downloadCompletionTime = data.durationInMillis;
          _downloadProgress = '100';
        });
      },
      onUploadComplete: (TestResult data) {
        setState(() {
          _uploadRate = data.transferRate;
          _uploadCompletionTime = data.durationInMillis;
          _uploadProgress = '100';
        });
      },
      onCompleted: (TestResult download, TestResult upload) {
        setState(() => _testInProgress = false);
      },
      onError: (String errorMessage, String speedTestError) {
        reset();
      },
      onDefaultServerSelectionInProgress: () {
        setState(() => _isServerSelectionInProgress = true);
      },
      onDefaultServerSelectionDone: (Client? client) {
        setState(() {
          _isServerSelectionInProgress = false;
          _ip = client?.ip;
          _asn = client?.asn;
          _isp = client?.isp;
        });
      },
    );
  }

  // Widget _buildRadialGauge(double value, String label) {
  //   return SfRadialGauge(
  //     title: GaugeTitle(
  //       text: label,
  //       textStyle: const TextStyle(
  //         fontSize: 16.0,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     axes: <RadialAxis>[
  //       RadialAxis(
  //         minimum: 0,
  //         maximum: 100,
  //         showLabels: false,
  //         showTicks: false,
  //         ranges: <GaugeRange>[
  //           GaugeRange(
  //             startValue: 0,
  //             endValue: 100,
  //             color: Colors.green,
  //             startWidth: 10,
  //             endWidth: 10,
  //           ),
  //         ],
  //         pointers: <GaugePointer>[
  //           NeedlePointer(
  //             value: value,
  //             enableAnimation: true,
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildRadialGauge(double value, String label) {
  return SfRadialGauge(
    title: GaugeTitle(
      text: label,
      textStyle: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    axes: <RadialAxis>[
      RadialAxis(
        minimum: 0,
        maximum: 100,
        showLabels: false,
        showTicks: false,
        axisLineStyle: AxisLineStyle(
          thickness: 0.2,
          cornerStyle: CornerStyle.bothCurve,
          color: Colors.blueGrey,
          thicknessUnit: GaugeSizeUnit.factor,
        ),
        pointers: <GaugePointer>[
          RangePointer(
            value: value,
            cornerStyle: CornerStyle.bothCurve,
            width: 0.2,
            sizeUnit: GaugeSizeUnit.factor,
            gradient: const SweepGradient(
              colors: <Color>[Colors.green, Colors.red],
              stops: <double>[0.25, 0.75],
            ),
          ),
          MarkerPointer(
            value: value,
            markerType: MarkerType.circle,
            color: Colors.white,
          )
        ],
        annotations: <GaugeAnnotation>[
          GaugeAnnotation(
            widget: Text(
              '$value%',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            angle: 90,
            positionFactor: 0.5,
          )
        ],
      ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internet Speed Test'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildRadialGauge(double.parse(_downloadProgress), 'Download'),
                Text('Download Rate: $_downloadRate $_unitText'),
                if (_downloadCompletionTime > 0)
                  Text('Time: ${(_downloadCompletionTime / 1000).toStringAsFixed(2)}s'),
                _buildRadialGauge(double.parse(_uploadProgress), 'Upload'),
                Text('Upload Rate: $_uploadRate $_unitText'),
                if (_uploadCompletionTime > 0)
                  Text('Time: ${(_uploadCompletionTime / 1000).toStringAsFixed(2)}s'),
                const SizedBox(height: 20),
                if (!_testInProgress)
                  ElevatedButton(
                    onPressed: startTesting,
                    child: const Text('Start Test'),
                  ),
                if (_testInProgress)
                  const CircularProgressIndicator(),
                Text(
                  _isServerSelectionInProgress
                      ? 'Selecting Server...'
                      : 'IP: ${_ip ?? '--'} | ASN: ${_asn ?? '--'} | ISP: ${_isp ?? '--'}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
