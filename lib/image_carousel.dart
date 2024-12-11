import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imgList;

  ImageCarousel({required this.imgList});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.2,
        autoPlay: true,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
      ),
      items: imgList.map((item) => Container(
        child: Center(
          child: Image.network(
            item,
            fit: BoxFit.cover,
            width: 1000,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      )).toList(),
    );
  }
}