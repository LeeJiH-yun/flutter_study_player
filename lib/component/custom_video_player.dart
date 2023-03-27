import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed; //외부에서 받기 위해

  const CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    Key? key
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  Duration currentPosition = Duration(); //현재 영상의 위치를 저장할 변수
  bool showControls = false;

  @override
  void initState() { //맨 처음만 실행
    super.initState();

    initializeController();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) { //실행 이후 파라미터만 변경 됐을 때[새로운 영상 선택했을 때]
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video.path != widget.video.path) { //새로운 위젯이 생성 되기 전의 위젯=oldWidget
      //widget은 현재 위젯
      initializeController(); //컨트롤러 초기화
    }
  }

  void initializeController() async {
    currentPosition = Duration(); //영상을 처음부터 틀어주기

    videoController = VideoPlayerController.file(
        File(widget.video.path)
    );

    await videoController!.initialize(); //위에서 videoConroller를 넣어 줬기 때문에 !붙인다.

    videoController!.addListener(() async{ //영상 실행 되는 포지션이 변경될 때 (슬라이더가 변경이 안되서 이 부분 사용)
      final currentPosition = videoController!.value.position;

      setState(() {
        this.currentPosition = currentPosition;
      });
    });
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      //initState에서 initializeController함수가 다 실행되기까지 기다리지 않기 때문에 널이 들어갈 수 있다.
      return CircularProgressIndicator(); //그럴 경우 로딩 추가
    }

    return AspectRatio(
        aspectRatio: videoController!.value.aspectRatio, //비디오의 비율대로 보이게 한다.
        child: GestureDetector(
          onTap: (){
            setState(() { //화면 클릭시 아이콘들이 안 보이게 설정
              showControls = !showControls;
            });
          },
          child: Stack(
            children: [
              VideoPlayer(
                videoController!
              ),
              if (showControls)
                _Controls(
                onPlayPressed: onPlayPressed,
                onForwardPressed: onForwardPressed,
                onReversePressed: onReversePressed,
                isPlaying: videoController!.value.isPlaying,
              ),
              if (showControls)
                _NewVideo(onPressed: widget.onNewVideoPressed),
              _SliderBottom(
                currentPosition: currentPosition,
                maxPosition: videoController!.value.duration,
                onSliderChanged: onSliderChanged
              )
            ]
          ),
        )
    );
  }

  void onSliderChanged(double val){

  }

  void onReversePressed(){
    final currentPosition = videoController!.value.position; //영상 어느 포지션을 실행중인지

    Duration position = Duration(); // 기본 0초로 셋팅

    //영상이 실행 중이기 전에 누르는 것을 방지
    if (currentPosition.inSeconds > 3) { //현재 실행 하는 부분이 3초보다 더 됐을 경우
      position = currentPosition - Duration(seconds: 3);  //3초 뒤로 가기
    }

    videoController!.seekTo(position);
  }

  void onForwardPressed(){
    final maxPosition = videoController!.value.duration; //영상 전체 길이를 가져온다.
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds > currentPosition.inSeconds) {
      //전체 영상 길이에 3초를 뺀 거보다 현재 영상 부분이 짧을 경우
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onPlayPressed(){
    //이미 실행 중이면 중지 아니면 실행
    setState(() {
      if (videoController!.value.isPlaying) { //실행 하고 있는지 알 수 있는 값 isPlaying
        videoController!.pause();
      }
      else {
        videoController!.play();
      }
    });
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying; //실행 중인지 여부

  const _Controls({
    required this.onPlayPressed,
    required this.onReversePressed,
    required this.onForwardPressed,
    required this.isPlaying,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height, //높이를 최대로 만들어준다.
      color: Colors.black.withOpacity(0.5), //투명도 추가 = withOpacity
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          renderIconButton(
              onPressed: onReversePressed,
              iconData: Icons.rotate_left
          ),
          renderIconButton(
              onPressed: onPlayPressed,
              iconData: isPlaying ? Icons.pause : Icons.arrow_forward_outlined
          ),
          renderIconButton(
              onPressed: onForwardPressed,
              iconData: Icons.rotate_right
          ),
        ],
      ),
    );
  }

  Widget renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30.0,
      color: Colors.white,
      icon: Icon(iconData)
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewVideo({
    required this.onPressed,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned( //위치를 정하는 위젯
      right: 0,//오른쪽 끝에서 부터 0 픽셀만큼 이동을 시켜라
      child: IconButton(
          onPressed: onPressed,
          color: Colors.white,
          iconSize: 30.0,
          icon: Icon(Icons.photo_camera_back)
      ),
    );
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom({
    required this.currentPosition,
    required this.maxPosition,
    required this.onSliderChanged,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
            children: [
              Text( //padLeft
                '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              Expanded(
                child: Slider(
                  max: maxPosition.inSeconds.toDouble(), //double값이 들어가야하므로
                  min: 0,
                  value: currentPosition.inSeconds.toDouble(), //숫자로 변경
                  onChanged: onSliderChanged
                ),
              ),
              Text( //padLeft
                '${maxPosition.inMinutes}:${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ]
        ),
      ),
    );
  }
}
