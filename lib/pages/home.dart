import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../widget/entry.dart' as widgets;
import '../tool/api.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool loading = false;
  List<String> images = [];
  bool editMode = false;
  int imageSaved = 0;
  bool downloading = false;

  Future<void> saveToGallery() async {
    if (images.isNotEmpty) {
      setState(() {
        downloading = true;
      });
      for (final String imageUrl in images) {
        await GallerySaver.saveImage(imageUrl, albumName: 'image-downloader');
        imageSaved ++;
        setState(() {});
      }
      setState(() {
        downloading = false;
      });
    }
  }

  Future<void> getImageList(String text) async {
    String url = text.trimLeft().trimRight();
    if (url.isNotEmpty) {
      setState(() {
        editMode = false;
        loading = true;
      });
      List<String> list = await getImages(url);
      setState(() {
        images = list;
        loading = false;
      });
    }
    else {
      Fluttertoast.showToast(
        msg: '目标地址找不到图片',
        gravity: ToastGravity.BOTTOM
      );
    }
  }

  Widget imageWidget(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String url) => const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (BuildContext context, String url, error) => const Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: <Widget>[
          widgets.Card(
            child: TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '图片地址'
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.send,
              onSubmitted: (String text) {
                getImageList(text);
              },
            ),
          ),
          Expanded(
              child: Stack(
                children: [
                  widgets.Card(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Container(
                      constraints: const BoxConstraints.expand(),
                      child: images.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('获取到${images.length}张图片'),
                                IconButton(
                                    onPressed: () {
                                      if (!downloading) {
                                        setState(() {
                                          editMode = !editMode;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                        editMode ? Icons.done : Icons.edit_note
                                    )
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                GridView(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3
                                  ),
                                  children: images.map((String url) => Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      InkWell(
                                        child: imageWidget(url),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) => Scaffold(
                                                appBar: AppBar(
                                                  title: const Text('预览'),
                                                ),
                                                body: Center(
                                                  child: imageWidget(url),
                                                ),
                                                backgroundColor: Colors.black.withOpacity(.4),
                                              )
                                          );
                                        },
                                      ),
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Offstage(
                                          offstage: !editMode,
                                          child: Container(
                                            constraints: const BoxConstraints.expand(),
                                            color: Colors.black.withOpacity(.4),
                                            child: IconButton(
                                              icon: const Icon(Icons.delete_forever_outlined, color: Colors.red, size: 36),
                                              onPressed: () {
                                                images.remove(url);
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )).toList(),
                                ),
                                AnimatedPositioned(
                                  left: 0,
                                  bottom: downloading ? 0 : -60,
                                  right: 0,
                                  duration: const Duration(microseconds: 400),
                                  child: Container(
                                    color: Colors.black.withOpacity(.75),
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      '图片下载中 $imageSaved / ${images.length}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ) : const Center(
                        child: Text('暂无图片'),
                      ),
                    ),
                  ),
                  widgets.LoadingOverlay(
                    open: loading,
                  )
                ],
              )
          )
        ],
      ),
      floatingActionButton: images.isNotEmpty ? FloatingActionButton(
        onPressed: saveToGallery,
        tooltip: '保存到相册',
        child: const Icon(Icons.download),
      ) : null, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}