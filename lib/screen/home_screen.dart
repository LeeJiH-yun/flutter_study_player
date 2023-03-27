import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_study_player/component/custom_video_player.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video; //모든 이미지와 비디오를 리턴 받을 수 있다.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: video == null ? renderEmpty() : renderVideo(),
    );
  }

  Widget renderVideo() {
    return Center(
      child: CustomVideoPlayer(
        video: video!,
        onNewVideoPressed: onNewVideoPressed, //이미지 버튼을 눌렀을 때 새로운 영상을 선택할 수 있게끔
      ),
      //그냥 video만 썼을 때 오류가 나는데 이유는 널일 수 있어서 이다. 하지만 위에서 video 널 체크를 if문으로 했기에 무조건 널이 아니니까 !를 붙여서 해결
    );
  }

  Widget renderEmpty (){
    return Container(
      width: MediaQuery.of(context).size.width, //Stateful로 바꿈으로 어떤 함수에서든 context를 자동으로 가져온다.
      decoration: getBoxDecoration(),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Logo(onTap: onNewVideoPressed),
            SizedBox(height: 30.0),
            _AppName()
          ]
      ),
    );
  }

  void onNewVideoPressed() async {
    final video = await ImagePicker().pickVideo(
        source: ImageSource.gallery
    );

    if (video != null) { //비디오를 골랐을 때
      setState(() {
        this.video = video;
      });
    }
  }

  BoxDecoration getBoxDecoration(){
    return BoxDecoration(
      gradient: LinearGradient( //LinearGradient = 일괄적으로 색이 점차 바뀐다.
          begin: Alignment.topCenter, //색이어디서 시작할지
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A3A7C),
            Color(0xFF000118)
          ]
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;

  const _Logo({
    required this.onTap,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        'asset/image/logo.png'
      ),
    );
  }
}

class _AppName extends StatelessWidget {
  const _AppName({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontWeight: FontWeight.w300
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            'VIDEO',
            style: textStyle
        ),
        Text(
            'PLAYER',
            style: textStyle.copyWith(
                fontWeight: FontWeight.w700
            )
        ),
      ],
    );
  }
}
