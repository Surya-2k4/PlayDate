import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const Text(
            "Find your favorite song",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            style: const TextStyle(color: AppTheme.textBlack),
            decoration: InputDecoration(
              hintText: "Search song name...",
              hintStyle: const TextStyle(color: AppTheme.textGrey),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryPink),
              filled: true,
              fillColor: AppTheme.softGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: AppTheme.primaryPink),
                onPressed: _search,
              ),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryPink),
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
                            context.read<PlayerProvider>().playVideo(
                              video.id.value,
                            );
                            Navigator.pop(context);
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
