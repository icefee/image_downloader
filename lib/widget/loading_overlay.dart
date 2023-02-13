import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool open;
  const LoadingOverlay({ super.key, required this.open });
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (!open) {
      return Container();
    }
    return Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: Center(
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.75),
              borderRadius: BorderRadius.circular(5.0)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text('加载中..', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        )
    );
  }
}
