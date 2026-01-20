import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/player_provider.dart';
import '../../core/constants/utils/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final YoutubeExplode _yt = YoutubeExplode();
  List<Video> _results = [];
  bool _isLoading = false;

  void _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final searchList = await _yt.search.search(query);
      setState(() {
        _results = searchList.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error searching YouTube")),
        );
      }
    }
  }

  void _showQueue() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<PlayerProvider>(
        builder: (context, player, child) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.queue_music_rounded,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Playlist Stack",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textBlack,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${player.queue.length} songs",
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: player.queue.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_off_rounded,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Queue is empty.\nSearch for songs to add!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        )
                      : ReorderableListView.builder(
                          scrollController: scrollController,
                          itemCount: player.queue.length,
                          onReorder: (oldIndex, newIndex) {
                            player.reorderQueue(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final song = player.queue[index];
                            return ListTile(
                              key: ValueKey(song['id'] + index.toString()),
                              onTap: () {
                                player.playVideo(song['id']);
                                player.removeFromQueue(index);
                                Navigator.pop(context); // Close queue
                                Navigator.pop(context); // Close search
                              },
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  song['thumbnail'],
                                  width: 50,
                                  height: 35,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                song['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                song['author'],
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 20),
                                    onPressed: () =>
                                        player.removeFromQueue(index),
                                  ),
                                  const Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                "Find your favorite song",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBlack,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Consumer<PlayerProvider>(
                  builder: (context, player, child) => Badge(
                    label: Text(player.queue.length.toString()),
                    isLabelVisible: player.queue.isNotEmpty,
                    backgroundColor: theme.primaryColor,
                    textColor: Colors.white,
                    child: IconButton(
                      icon: Icon(
                        Icons.queue_music_rounded,
                        color: theme.primaryColor,
                      ),
                      onPressed: _showQueue,
                      tooltip: "Playlist Stack",
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: const TextStyle(color: AppTheme.textBlack),
            decoration: InputDecoration(
              hintText: "Search song name...",
              hintStyle: const TextStyle(color: AppTheme.textGrey),
              prefixIcon: Icon(Icons.search, color: theme.primaryColor),
              filled: true,
              fillColor: AppTheme.softGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: theme.primaryColor),
                onPressed: _search,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(theme.primaryColor),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final video = _results[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.softGrey,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.network(
                                  video.thumbnails.lowResUrl,
                                  width: 100,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black12,
                                    child: const Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: AppTheme.textGrey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    video.author,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            final player = context.read<PlayerProvider>();
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(24),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(30),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 24),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const Text(
                                      "Song Options",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textBlack,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: theme.primaryColor
                                            .withOpacity(0.1),
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      title: const Text(
                                        "Play Now",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onTap: () {
                                        player.playVideo(video.id.value);
                                        Navigator.pop(context); // Close sheet
                                        Navigator.pop(context); // Close search
                                      },
                                    ),
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orange
                                            .withOpacity(0.1),
                                        child: const Icon(
                                          Icons.queue_music_rounded,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      title: const Text(
                                        "Add to Queue",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onTap: () {
                                        player.addToQueue({
                                          'id': video.id.value,
                                          'title': video.title,
                                          'author': video.author,
                                          'thumbnail':
                                              video.thumbnails.lowResUrl,
                                        });
                                        Navigator.pop(context); // Close sheet
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("Added to queue!"),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: theme.primaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
