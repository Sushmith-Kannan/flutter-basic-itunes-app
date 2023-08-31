import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

const String downloadPath =
    'music_downloads'; // Directory to store downloaded songs
bool isLoading = false;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Colors.teal,
        hintColor: Colors.teal,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen size
    Size screenSize = MediaQuery.of(context).size;

    // Calculate responsive font size based on screen width
    double titleFontSize = screenSize.width * 0.06;
    double subtitleFontSize = screenSize.width * 0.03;

    // Calculate responsive padding based on screen width
    EdgeInsetsGeometry titleContainerPadding = EdgeInsets.only(
      top: screenSize.height * 0.2,
      left: screenSize.width * 0.23,
    );
    EdgeInsetsGeometry subtitleContainerPadding = EdgeInsets.only(
      top: screenSize.height * 0.235,
      left: screenSize.width * 0.23,
    );

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents the wallpaper from resizing when the keyboard pops up
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            // Set the background image here
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/theme.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: Container(
              alignment: Alignment.center,
              child: SearchBar(),
            ),
          ),
          Positioned(
            child: Padding(
              padding: titleContainerPadding,
              child: Container(
                child: Text(
                  "Eternal 30's",
                  style: GoogleFonts.brunoAce(
                    textStyle: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Color.fromRGBO(55, 138, 138, 1),
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            child: Padding(
              padding: subtitleContainerPadding,
              child: Container(
                child: Text(
                  "Developed by sushmith",
                  style: GoogleFonts.spaceGrotesk(
                    textStyle: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Color.fromRGBO(55, 138, 138, 1),
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DownloadedSongsPage(),
            ),
          );
        },
        child: Text("Downloaded"),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  String query = '';
  Future<void> searchMusic() async {
    setState(() {
      isLoading = true;
    });
    final String baseUrl =
        'https://itunes.apple.com/search?media=music&entity=song&term=';

    if (query.trim().isEmpty) {
      return;
    }

    final String url = baseUrl + Uri.encodeQueryComponent(query);
    final response = await http.get(Uri.parse(url));
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List results = data['results'];
      for (int i = 0; i < results[0].length; i++) {
        print(results[0].keys.toList()[i]);
        print(results[0].values.toList()[i]);
      }
      print(results[0].keys);
      if (results.isNotEmpty) {
        final Map<String, dynamic> firstSong = results[0];
        final int songDuration = firstSong['trackTimeMillis'] ?? 0;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicPage(
              results: results,
              songDuration: songDuration,
            ),
          ),
        );
      }
    } else {
      print('Failed to fetch music.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return !isLoading
        ? Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  onSubmitted: (value) {
                    searchMusic();
                  },
                  decoration: InputDecoration(
                      labelText: 'Search Music',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.teal),
                      hintStyle: TextStyle(color: Colors.teal),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal))),
                ),
              ),
              // Positioned(
              //   top: screenSize.height * 0.08,
              //   left: screenSize.width * 0.0,
              //   right: screenSize.width * 0.01,
              //   child:
              SizedBox(
                height: screenSize.height * 0.06,
                width: screenSize.width * 0.9,
                child: ElevatedButton(
                    onPressed: () {
                      searchMusic();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: Text("Search")),
              ),
              // )
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}

class MusicPage extends StatelessWidget {
  final List<dynamic> results;
  final int songDuration;

  const MusicPage(
      {super.key, required this.results, required this.songDuration});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // Calculate responsive font size based on screen width
    double titleFontSize = screenSize.width * 0.06;
    double subtitleFontSize = screenSize.width * 0.03;

    // Calculate responsive padding based on screen width
    EdgeInsetsGeometry titleContainerPadding = EdgeInsets.only(
      top: screenSize.height * 0.2,
      left: screenSize.width * 0.33,
    );
    EdgeInsetsGeometry subtitleContainerPadding = EdgeInsets.only(
      top: screenSize.height * 0.235,
      left: screenSize.width * 0.23,
    );
    return Scaffold(
      body: Stack(children: [
        Image.asset(
          'assets/images/theme.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 250),
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> song = results[index];
              final String songUrl = song['previewUrl'];
              final String songTitle = song['trackName'];
              final String cardImage = song['artworkUrl100'];

              return ListTile(
                title: Text(songTitle),
                subtitle: Text(song['artistName']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongPlayerPage(
                        songUrl: songUrl,
                        songTitle: songTitle,
                        cardImage: cardImage,
                        songDuration: songDuration,
                        isDownloaded: false, // This song is online
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Positioned(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 250.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  //Blur Effect
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(),
                  ),
                  //Gradient Effect
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.20)),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ]),
                    ),
                  ),
                  //Child
                  Positioned(
                    child: Padding(
                      padding: titleContainerPadding,
                      child: Container(
                        child: Text(
                          "Results",
                          style: GoogleFonts.brunoAce(
                            textStyle: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Color.fromRGBO(55, 138, 138, 1),
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class SongPlayerPage extends StatefulWidget {
  final String songUrl;
  final String songTitle;
  final String cardImage;
  final int songDuration;
  final bool isDownloaded;

  const SongPlayerPage({
    super.key,
    required this.songUrl,
    required this.songTitle,
    required this.cardImage,
    required this.songDuration,
    required this.isDownloaded,
  });

  @override
  _SongPlayerPageState createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  bool isRepeating = false;
  Duration duration = Duration(seconds: 0);
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    setState(() {
      duration = Duration(milliseconds: widget.songDuration);
    });

    audioPlayer = AudioPlayer();

    if (widget.isDownloaded) {
      // If the song is downloaded, set the file path as the URL
      audioPlayer.setFilePath(widget.songUrl);
    } else {
      // If the song is not downloaded, set the online URL
      audioPlayer.setUrl(widget.songUrl);
    }

    audioPlayer.durationStream.listen((d) {
      if (mounted) {
        setState(() {
          duration = d ?? Duration.zero;
        });
      }
    });

    audioPlayer.positionStream.listen((p) {
      if (mounted) {
        setState(() {
          position = p ?? Duration.zero;
        });
      }
    });

    audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          isPlaying = playerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void startPlaying() async {
    await audioPlayer.play();
  }

  void pauseSong() async {
    await audioPlayer.pause();
  }

  void toggleRepeat() {
    setState(() {
      isRepeating = !isRepeating;
    });
  }

  void onSliderChanged(double value) {
    setState(() {
      position =
          Duration(milliseconds: (value * duration.inMilliseconds).round());
    });
    audioPlayer.seek(position);
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Stack(children: [
        // Background Image with Blur Effect
        Image.network(
          widget.cardImage,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Rest of the content (Music Player UI)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SongCard(
              songTitle: widget.songTitle,
              cardImage: widget.cardImage,
              songUrl: widget.songUrl,
              isDownloaded: widget.isDownloaded,
            ),
            SizedBox(height: 20),
            Slider(
              value: position.inMilliseconds / duration.inMilliseconds,
              onChanged: onSliderChanged,
              onChangeEnd: (value) {
                final newPosition = Duration(
                    milliseconds: (value * duration.inMilliseconds).round());
                setState(() {
                  position = newPosition;
                });
                audioPlayer.seek(newPosition);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(position),
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    formatDuration(duration),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: isPlaying ? pauseSong : startPlaying,
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                SizedBox(width: 16),
                IconButton(
                  onPressed: toggleRepeat,
                  icon: Icon(isRepeating ? Icons.repeat : Icons.repeat_one),
                ),
                SizedBox(width: 16),
                if (!widget
                    .isDownloaded) // Show the download button only for online songs
                  IconButton(
                    onPressed: () {
                      _downloadSong(context);
                    },
                    icon: Icon(Icons.download),
                  ),
              ],
            ),
          ],
        ),
      ]),
    ));
  }

  Future<void> _downloadSong(BuildContext context) async {
    final downloadDirPath = await _getDownloadsPath();
    final songFilename =
        widget.songUrl.substring(widget.songUrl.lastIndexOf('/') + 1);
    final downloadedFile = File('$downloadDirPath/$songFilename');

    // Check if the song is already downloaded
    if (downloadedFile.existsSync()) {
      Fluttertoast.showToast(msg: 'Song is already downloaded.');
      return;
    }

    final response = await http.get(Uri.parse(widget.songUrl));
    if (response.statusCode == 200) {
      final songBytes = response.bodyBytes;
      await downloadedFile.writeAsBytes(songBytes);
      Fluttertoast.showToast(msg: 'Song downloaded successfully.');
    } else {
      Fluttertoast.showToast(msg: 'Failed to download song.');
    }
  }

  Future<String> _getDownloadsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$downloadPath';
  }
}

class SongCard extends StatelessWidget {
  final String songTitle;
  final String cardImage;
  final String songUrl;
  final bool isDownloaded;

  const SongCard({
    super.key,
    required this.songTitle,
    required this.cardImage,
    required this.songUrl,
    required this.isDownloaded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SongPlayerPage(
              songUrl: songUrl,
              songTitle: songTitle,
              cardImage: cardImage,
              songDuration: 0,
              isDownloaded: isDownloaded,
            ),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isDownloaded
                  ? _buildDownloadedSongCardImage()
                  : _buildOnlineSongCardImage(),
              SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    songTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Add other widgets below the title as needed
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadedSongCardImage() {
    return Icon(
      Icons.music_note,
      size: 100,
    );
  }

  Widget _buildOnlineSongCardImage() {
    return Container(
      height: 300,
      width: 300,
      child: Image.network(
        cardImage,
        fit: BoxFit.contain,
      ),
    );
  }
}

class DownloadedSongsPage extends StatefulWidget {
  @override
  _DownloadedSongsPageState createState() => _DownloadedSongsPageState();
}

class _DownloadedSongsPageState extends State<DownloadedSongsPage> {
  List<String> downloadedSongs = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedSongs();
  }

  void _loadDownloadedSongs() async {
    final downloadDirPath = await _getDownloadsPath();
    final directory = Directory(downloadDirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final downloadedFiles = await directory.list().toList();
    setState(() {
      downloadedSongs = downloadedFiles.map((file) => file.path).toList();
    });
  }

  Future<String> _getDownloadsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$downloadPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Set the background image here
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/theme.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: downloadedSongs.length,
          itemBuilder: (context, index) {
            final String songPath = downloadedSongs[index];
            final String songTitle =
                songPath.substring(songPath.lastIndexOf('/') + 1);
            return ListTile(
              title: Text(songTitle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongPlayerPage(
                      songUrl: songPath,
                      songTitle: songTitle,
                      cardImage: '', // No image needed for downloaded songs.
                      songDuration:
                          0, // Set song duration to 0 as it's not required in this context.
                      isDownloaded: true, // This song is downloaded
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
