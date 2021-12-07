// import 'package:audio_service/audio_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:musicplayer/AudioPlayerTask.dart';
// import 'package:musicplayer/SeekBar.dart';
// import 'package:musicplayer/models.dart';
// import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:rxdart/rxdart.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
//   final _player = AudioPlayer();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addObserver(this);
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarColor: Colors.black,
//     ));
//     AudioService.start(
//       backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
//       androidNotificationChannelName: 'Audio Service Demo',
//       // Enable this if you want the Android service to exit the foreground state on pause.
//       //androidStopForegroundOnPause: true,
//       androidNotificationColor: 0xFF2196f3,
//       androidNotificationIcon: 'mipmap/ic_launcher',
//       androidEnableQueue: true,
//     );
//   }

//   bool loading = false;

//   _init() {
//     setState(() {
//       loading = true;
//     });

//     setState(() {
//       loading = false;
//     });
//   }

//   void _audioPlayerTaskEntrypoint() async {
//     AudioServiceBackground.run(() => AudioPlayerTask());
//   }

//   final PanelController _pc = PanelController();
//   bool downloaded = false;
//   bool favourite = false;
//   double sliderLength = 0.0;
//   bool isPlay = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: StreamBuilder<QueueState>(
//           stream: _queueStateStream,
//           builder: (context, snapshot) {
//             final queueState = snapshot.data;
//             final queue = queueState?.queue ?? [];
//             final mediaItem = queueState?.mediaItem;
//             return SlidingUpPanel(
//               minHeight: 75,
//               maxHeight: MediaQuery.of(context).size.height -
//                   MediaQuery.of(context).padding.top,
//               renderPanelSheet: false,
//               controller: _pc,
//               panel: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.all(Radius.circular(24.0)),
//                     boxShadow: [
//                       BoxShadow(
//                         blurRadius: 16.0,
//                         color: Colors.white10,
//                       ),
//                     ]),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       WillPopScope(
//                         onWillPop: () async {
//                           setState(() {
//                             _pc.panelPosition = 0;
//                           });
//                           return false;
//                         },
//                         child: Container(
//                           height: MediaQuery.of(context).size.height -
//                               MediaQuery.of(context).padding.top -
//                               16,
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   IconButton(
//                                     onPressed: () async {
//                                       setState(() {
//                                         _pc.panelPosition = 0;
//                                       });
//                                     },
//                                     icon: Icon(
//                                       Icons.arrow_back_ios_new,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: () async {},
//                                     icon: Icon(
//                                       Icons.menu,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 ],
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.all(24),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     color: Colors.redAccent,
//                                     image: DecorationImage(
//                                       image: NetworkImage(
//                                         mediaItem == null
//                                             ? "https://wallpapercave.com/wp/wp3377140.jpg"
//                                             : "https://" +
//                                                 mediaItem.artUri!.host +
//                                                 mediaItem.artUri!.path,
//                                       ),
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.50,
//                                 ),
//                               ),
//                               Spacer(),
//                               Text(
//                                 mediaItem == null
//                                     ? "No Audio Selected"
//                                     : mediaItem.title,
//                                 style: TextStyle(
//                                   color: Colors.orangeAccent,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 24,
//                                 ),
//                               ),
//                               Text(
//                                 mediaItem == null ? "" : mediaItem.album,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               StreamBuilder<MediaState>(
//                                 stream: _mediaStateStream,
//                                 builder: (context, snapshot) {
//                                   final mediaState = snapshot.data;
//                                   return SeekBar(
//                                     duration: mediaState?.mediaItem?.duration ??
//                                         Duration.zero,
//                                     position:
//                                         mediaState?.position ?? Duration.zero,
//                                     onChangeEnd: (newPosition) {
//                                       AudioService.seekTo(newPosition);
//                                     },
//                                   );
//                                 },
//                               ),
//                               Spacer(),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceAround,
//                                 children: [
//                                   InkWell(
//                                     child: Icon(
//                                       favourite
//                                           ? Icons.favorite
//                                           : Icons.favorite_outline,
//                                       color: Colors.white,
//                                       size: 28,
//                                     ),
//                                     onTap: () {
//                                       setState(() {
//                                         favourite = !favourite;
//                                       });
//                                     },
//                                   ),
//                                   InkWell(
//                                     child: Icon(
//                                       Icons.skip_previous_rounded,
//                                       color: Colors.white,
//                                       size: 36,
//                                     ),
//                                     onTap: () {},
//                                   ),
//                                   StreamBuilder<bool>(
//                                     stream: AudioService.playbackStateStream
//                                         .map((state) => state.playing)
//                                         .distinct(),
//                                     builder: (context, snapshot) {
//                                       final playing = snapshot.data ?? false;
//                                       return Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           if (playing)
//                                             pauseButton()
//                                           else
//                                             playButton(),
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                   InkWell(
//                                     child: Icon(
//                                       Icons.skip_next_rounded,
//                                       color: Colors.white,
//                                       size: 36,
//                                     ),
//                                     onTap: () {},
//                                   ),
//                                   InkWell(
//                                     child: Icon(
//                                       downloaded
//                                           ? Icons.download_done
//                                           : Icons.download,
//                                       color: Colors.white,
//                                       size: 28,
//                                     ),
//                                     onTap: () {
//                                       setState(() {
//                                         downloaded = !downloaded;
//                                       });
//                                     },
//                                   ),
//                                 ],
//                               ),
//                               Spacer(),
//                               Spacer(),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.orangeAccent.withOpacity(0.3),
//                         ),
//                         padding: EdgeInsets.all(12),
//                         child: ListView.builder(
//                           padding: EdgeInsets.all(0),
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: queue.length,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             return ListTile(
//                               onLongPress: () {
//                                 setState(() {
//                                   AudioService.queue!.removeAt(index);
//                                 });
//                                 AudioService.play();
//                               },
//                               onTap: () {
//                                 setState(() {
//                                   AudioService.skipToQueueItem(queue[index].id);
//                                 });
//                                 AudioService.play();
//                               },
//                               leading: Container(
//                                 height: 50,
//                                 width: 50,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   color: Colors.redAccent,
//                                   image: DecorationImage(
//                                     image: NetworkImage(
//                                       mediaItem == null
//                                           ? "https://wallpapercave.com/wp/wp3377140.jpg"
//                                           : "https://" +
//                                               queue[index].artUri!.host +
//                                               queue[index].artUri!.path,
//                                     ),
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 queue[index].title,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               collapsed: InkWell(
//                 onTap: () async {
//                   await _pc.open();
//                 },
//                 child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[800],
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(16.0),
//                           topRight: Radius.circular(16.0)),
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Container(
//                               height: 50,
//                               width: 50,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: Colors.redAccent,
//                                 image: DecorationImage(
//                                   image: NetworkImage(
//                                     mediaItem == null
//                                         ? "https://wallpapercave.com/wp/wp3377140.jpg"
//                                         : "https://" +
//                                             mediaItem.artUri!.host +
//                                             mediaItem.artUri!.path,
//                                   ),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           flex: 2,
//                         ),
//                         Expanded(
//                           child: Container(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   mediaItem == null ? "" : mediaItem.title,
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 18),
//                                 ),
//                                 Text(
//                                   mediaItem == null
//                                       ? ""
//                                       : mediaItem.artist.toString(),
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           flex: 5,
//                         ),
//                         Expanded(
//                           child: Container(
//                             child: Row(
//                               children: [
//                                 InkWell(
//                                   child: Icon(
//                                     Icons.skip_previous_rounded,
//                                     color: Colors.white,
//                                     size: 32,
//                                   ),
//                                   onTap: AudioService.skipToPrevious,
//                                 ),
//                                 InkWell(
//                                   child: Icon(
//                                     Icons.play_arrow_rounded,
//                                     size: 40,
//                                     color: Colors.white,
//                                   ),
//                                   onTap: AudioService.play,
//                                 ),
//                                 InkWell(
//                                   child: Icon(
//                                     Icons.skip_next_rounded,
//                                     color: Colors.white,
//                                     size: 32,
//                                   ),
//                                   onTap: AudioService.skipToNext,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           flex: 3,
//                         ),
//                       ],
//                     )),
//               ),
//               body: Center(
//                 child: Text(
//                   "This is the Widget behind the sliding panel",
//                   style: TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             );
//           }),
//     );
//   }

//   /// A stream reporting the combined state of the current media item and its
//   /// current position.
//   Stream<MediaState> get _mediaStateStream =>
//       Rx.combineLatest2<MediaItem?, Duration, MediaState>(
//           AudioService.currentMediaItemStream,
//           AudioService.positionStream,
//           (mediaItem, position) => MediaState(mediaItem, position));

//   /// A stream reporting the combined state of the current queue and the current
//   /// media item within that queue.
//   Stream<QueueState> get _queueStateStream =>
//       Rx.combineLatest2<List<MediaItem>?, MediaItem?, QueueState>(
//           AudioService.queueStream,
//           AudioService.currentMediaItemStream,
//           (queue, mediaItem) => QueueState(queue, mediaItem));

//   playButton() => InkWell(
//         child: Container(
//           height: 55,
//           width: 55,
//           decoration: BoxDecoration(
//             color: Colors.orangeAccent,
//             borderRadius: BorderRadius.circular(180),
//           ),
//           child: Icon(
//             Icons.play_arrow_rounded,
//             size: 40,
//             color: Colors.white,
//           ),
//         ),
//         onTap: AudioService.play,
//       );

//   pauseButton() => InkWell(
//         child: Container(
//           height: 55,
//           width: 55,
//           decoration: BoxDecoration(
//             color: Colors.orangeAccent,
//             borderRadius: BorderRadius.circular(180),
//           ),
//           child: Icon(
//             Icons.pause,
//             size: 40,
//             color: Colors.white,
//           ),
//         ),
//         onTap: AudioService.pause,
//       );
//   stopButton() => InkWell(
//         child: Container(
//           height: 55,
//           width: 55,
//           decoration: BoxDecoration(
//             color: Colors.orangeAccent,
//             borderRadius: BorderRadius.circular(180),
//           ),
//           child: Icon(
//             Icons.stop,
//             size: 40,
//             color: Colors.white,
//           ),
//         ),
//         onTap: AudioService.stop,
//       );
// }
