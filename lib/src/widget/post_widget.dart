import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ieatta/heart_icon_animator.dart';
import 'package:ieatta/heart_overlay_animator.dart';
import 'package:ieatta/src/models/models.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ieatta/src/widget/avatar_widget.dart';
import 'package:ieatta/src/widget/comment_widget.dart';
import 'package:ieatta/ui_utils.dart';

import 'post/add_comment_modal.dart';
import 'post/photo_carousel_indicator.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget(this.post);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final StreamController<void> _doubleTapImageEvents =
      StreamController.broadcast();
  bool _isSaved = false;
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _doubleTapImageEvents.close();
    super.dispose();
  }

  void _updateImageIndex(int index) {
    setState(() => _currentImageIndex = index);
  }

  void _onDoubleTapLikePhoto() {
    setState(() => widget.post.addLikeIfUnlikedFor(currentUser));
    _doubleTapImageEvents.sink.add(null);
  }

  void _toggleIsLiked() {
    setState(() => widget.post.toggleLikeFor(currentUser));
  }

  void _toggleIsSaved() {
    setState(() => _isSaved = !_isSaved);
  }

  void _showAddCommentModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: AddCommentModal(
            user: currentUser,
            onPost: (String text) {
              setState(() {
                widget.post.comments.add(Comment(
                  text: text,
                  user: currentUser,
                  commentedAt: DateTime.now(),
                  likes: [],
                ));
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // User Details
        Row(
          children: <Widget>[
            AvatarWidget(user: widget.post.user),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.post.user.name, style: bold),
                if (widget.post.location != null) Text(widget.post.location)
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => showSnackbar(context, 'More'),
            )
          ],
        ),
        // Photo Carosuel
        GestureDetector(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CarouselSlider(
                items: widget.post.imageUrls.map((url) {
                  return Image.asset(
                    url,
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.of(context).size.width,
                  );
                }).toList(),
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: _updateImageIndex,
              ),
              HeartOverlayAnimator(
                  triggerAnimationStream: _doubleTapImageEvents.stream),
            ],
          ),
          onDoubleTap: _onDoubleTapLikePhoto,
        ),
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HeartIconAnimator(
                isLiked: widget.post.isLikedBy(currentUser),
                size: 28.0,
                onTap: _toggleIsLiked,
                triggerAnimationStream: _doubleTapImageEvents.stream,
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 28.0,
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: _showAddCommentModal,
            ),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 28.0,
              icon: Icon(OMIcons.nearMe),
              onPressed: () => showSnackbar(context, 'Share'),
            ),
            Spacer(),
            if (widget.post.imageUrls.length > 1)
              PhotoCarouselIndicator(
                photoCount: widget.post.imageUrls.length,
                activePhotoIndex: _currentImageIndex,
              ),
            Spacer(),
            Spacer(),
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 28.0,
              icon:
                  _isSaved ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
              onPressed: _toggleIsSaved,
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Liked by
              if (widget.post.likes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: <Widget>[
                      Text('Liked by '),
                      Text(widget.post.likes[0].user.name, style: bold),
                      if (widget.post.likes.length > 1) ...[
                        Text(' and'),
                        Text(' ${widget.post.likes.length - 1} others',
                            style: bold),
                      ]
                    ],
                  ),
                ),
              // Comments
              if (widget.post.comments.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    children: widget.post.comments
                        .map((Comment c) => CommentWidget(c))
                        .toList(),
                  ),
                ),
              // Add a comment...
              Row(
                children: <Widget>[
                  AvatarWidget(
                    user: currentUser,
                    padding: EdgeInsets.only(right: 8.0),
                  ),
                  GestureDetector(
                    child: Text(
                      'Add a comment...',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: _showAddCommentModal,
                  ),
                ],
              ),
              // Posted Timestamp
              Text(
                widget.post.timeAgo(),
                style: TextStyle(color: Colors.grey, fontSize: 11.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
