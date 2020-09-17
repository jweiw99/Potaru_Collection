import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImgRetrieve {
  static CachedNetworkImage img(String id) {
    return CachedNetworkImage(
      imageUrl:
          "https://res.cloudinary.com/he0ptsmrc/image/upload/q_auto:eco/staff_directory/$id.jpg",
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                0.0, // horizontal, move right 10
                3.0, // vertical, move down 10
              ),
            )
          ],
          color: Colors.white,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  static CachedNetworkImage imgCircle(String id) {
    return CachedNetworkImage(
      imageUrl:
          "https://res.cloudinary.com/he0ptsmrc/image/upload/q_auto:eco/staff_directory/$id.jpg",
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape:BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
