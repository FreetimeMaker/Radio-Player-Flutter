import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Player (Flutter)',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RadioPlayerScreen(),
    );
  }
}

class RadioPlayerScreen extends StatefulWidget {
  const RadioPlayerScreen({super.key});

  @override
  State<RadioPlayerScreen> createState() => _RadioPlayerScreenState();
}

class _RadioPlayerScreenState extends State<RadioPlayerScreen> {
  late AudioPlayer _player;
  String? _currentStation;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  final List<Map<String, String>> _stations = [
    {
      "name": "Sunshine Radio",
      "url": "https://chmedia.streamabc.net/79-rsunshine-mp3-192-4746851?sABC=68s562rr%231%231699795900047_8633080%23puzrqvn-enqvb-jro&aw_0_1st.playerid=chmedia-radio-web&amsparams=playerid:chmedia-radio-web;skey:1760912110",
      "image": "assets/sunshine_logo.png"
    },
    {
      "name": "Radio Argovia",
      "url": "https://chmedia.streamabc.net/79-argovia-mp3-192-3024993?sABC=68s5qo3r%230%23q7s809s74070n543n7p5213q6qr39235%23qverpg&aw_0_1st.playerid=direct&amsparams=playerid:direct;skey:1760942910",
      "image": "assets/argovia_logo.png"
    },
    {
      "name": "Radio Pilatus",
      "url": "https://chmedia.streamabc.net/79-pilatus-mp3-192-4664468?sABC=68s5s266%230%23q7s809s74070n543n7p5213q6qr39235%23puzrqvn&aw_0_1st.playerid=chmedia&amsparams=playerid:chmedia;skey:1760948838",
      "image": "assets/pilatus_logo.png"
    },
    {
      "name": "SRF 3",
      "url": "http://livestreaming-node-2.srg-ssr.ch/srgssr/srf3/mp3/128",
      "image": "assets/srf3_logo.png"
    },
    {
      "name": "SRF 1",
      "url": "http://livestreaming-node-2.srg-ssr.ch/srgssr/srf1/mp3/128",
      "image": "assets/srf1_logo.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  Future<void> _playStation(String url, String name) async {
    await _player.setUrl(url);
    _player.play();
    setState(() => _currentStation = name);

    // 🔥 Log Firebase Analytics event
    await _analytics.logEvent(
      name: "station_played",
      parameters: {
        "station_name": name,
        "timestamp": DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Widget _buildStationRow(Map<String, String> station) {
    final isCurrent = _currentStation == station["name"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(station["image"]!, width: 55, height: 55),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: Text(
              station["name"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _playStation(station["url"]!, station["name"]!),
            child: Text(isCurrent ? "Playing…" : "Play"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Radio Player (Flutter)")),
      body: SingleChildScrollView(
        child: Column(
          children: _stations.map(_buildStationRow).toList(),
        ),
      ),
    );
  }
}
