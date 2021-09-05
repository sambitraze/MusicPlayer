import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musicplayer/common.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(
            "https://audiokumbh.s3.us-east-2.amazonaws.com/audiofile-file/1629782015177.mp3",
          ),
        ),
      );
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.stop();
    }
  }

  final PanelController _pc = PanelController();
  bool downloaded = false;
  bool favourite = false;
  double sliderLength = 0.0;
  bool isPlay = true;  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SlidingUpPanel(
        minHeight: 75,
        maxHeight: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top,
        renderPanelSheet: false,
        controller: _pc,
        panel: Container(
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 16.0,
                  color: Colors.white10,
                ),
              ]),
          child: SingleChildScrollView(
            child: Column(
              children: [
                WillPopScope(
                  onWillPop: () async {
                    setState(() {
                      _pc.panelPosition = 0;
                    });
                    return false;
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        16,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () async {
                                setState(() {
                                  _pc.panelPosition = 0;
                                });
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {},
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.redAccent,
                              image: DecorationImage(
                                image: NetworkImage(
                                  "https://cdn2.geckoandfly.com/wp-content/uploads/2017/12/530-album-cover.jpg",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            height: MediaQuery.of(context).size.height * 0.50,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "Titles",
                          style: TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          "SubTitle",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        StreamBuilder<PositionData>(
                          stream: _positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return SeekBar(
                              duration: positionData?.duration ?? Duration.zero,
                              position: positionData?.position ?? Duration.zero,
                              bufferedPosition:
                                  positionData?.bufferedPosition ??
                                      Duration.zero,
                              onChangeEnd: _player.seek,
                            );
                          },
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              child: Icon(
                                favourite
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                              onTap: () {
                                setState(() {
                                  favourite = !favourite;
                                });
                              },
                            ),
                            InkWell(
                              child: Icon(
                                Icons.skip_previous_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              onTap: () {},
                            ),
                            InkWell(
                              child: Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(180),
                                ),
                                child: Icon(
                                  isPlay ? Icons.play_arrow_rounded : Icons.pause,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                isPlay ? _player.play() : _player.pause();
                                setState(() {
                                  isPlay = !isPlay;
                                });
                              },
                            ),
                            InkWell(
                              child: Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              onTap: () {},
                            ),
                            InkWell(
                              child: Icon(
                                downloaded
                                    ? Icons.download_done
                                    : Icons.download,
                                color: Colors.white,
                                size: 28,
                              ),
                              onTap: () {
                                setState(() {
                                  downloaded = !downloaded;
                                });
                              },
                            ),
                          ],
                        ),
                        Spacer(),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  width: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.orangeAccent,
                  ),
                  child: Center(
                      child: Text(
                    "playlist",
                    textAlign: TextAlign.center,
                  )),
                )
              ],
            ),
          ),
        ),
        collapsed: InkWell(
          onTap: () async {
            await _pc.open();
          },
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.redAccent,
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://cdn2.geckoandfly.com/wp-content/uploads/2017/12/530-album-cover.jpg",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Titles",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Text(
                            "SubTitle",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    flex: 5,
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        children: [
                          InkWell(
                            child: Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            onTap: () {},
                          ),
                          InkWell(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 40,
                              color: Colors.orangeAccent,
                            ),
                            onTap: () {},
                          ),
                          InkWell(
                            child: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    flex: 3,
                  ),
                ],
              )),
        ),
        body: Center(
          child: Text(
            "This is the Widget behind the sliding panel",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
