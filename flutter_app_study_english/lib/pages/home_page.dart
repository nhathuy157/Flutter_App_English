import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_study_english/model/english_today.dart';
import 'package:flutter_app_study_english/pages/all_word_page.dart';
import 'package:flutter_app_study_english/pages/control_page.dart';
import 'package:flutter_app_study_english/values/app_colors.dart';
import 'package:flutter_app_study_english/values/share_keys.dart';
import 'package:flutter_app_study_english/widgets/app_button.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../packages/quote/qoute_model.dart';
import '../packages/quote/quote.dart';
import '../values/app_assets.dart';
import '../values/app_styles.dart';
import 'all_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currenIndex = 0;
  late PageController _pageController;

  List<EnglishToday> words = [];

  String quote = Quotes().getRandom().content!;

  List<int> fixedListRandom({int len = 1, int max = 120, int min = 1}) {
    if (len > max || len < min) {
      return [];
    }

    List<int> newList = [];

    Random random = Random();
    int count = 1;
    while (count <= len) {
      int val = random.nextInt(max);
      if (newList.contains(val)) {
        continue;
      } else {
        newList.add(val);
        count++;
      }
    }
    return newList;
  }

  getEnglishToday() async {
    SharedPreferences grefs = await SharedPreferences.getInstance();
    int len = grefs.getInt(ShareKeys.counter) ?? 5;
    List<String> newList = [];
    List<int> rans = fixedListRandom(len: len, max: nouns.length);
    rans.forEach((index) {
      newList.add(nouns[index]);
    });
    setState(() {
      words = newList.map((e) => getQuote(e)).toList();
    });
  }

  EnglishToday getQuote(String noun) {
    Quote? quote;
    quote = Quotes().getByWord(noun);
    return EnglishToday(
      noun: noun,
      quote: quote?.content,
      id: quote?.id,
    );
  }

  final GlobalKey<ScaffoldState> _scafflodKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController();
    super.initState();
    getEnglishToday();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scafflodKey,
      backgroundColor: AppColors.secondColor,
      appBar: AppBar(
        backgroundColor: AppColors.secondColor,
        elevation: 0,
        title: Text(
          'English today',
          style:
              AppStyles.h3.copyWith(color: AppColors.textColor, fontSize: 36),
        ),
        leading: InkWell(
          onTap: () {
            _scafflodKey.currentState?.openDrawer();
          },
          child: Image.asset(AppAssets.menu),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
                height: size.height * 1 / 10,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: Text(
                  '"$quote"',
                  style: AppStyles.h5.copyWith(
                    fontSize: 12,
                    color: AppColors.textColor,
                  ),
                )),
            Container(
                height: size.height * 2 / 3,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currenIndex = index;
                    });
                  },
                  itemCount: words.length > 5 ? 6 : words.length,
                  itemBuilder: (context, index) {
                    String firstLetter =
                        words[index].noun != null ? words[index].noun! : "";
                    firstLetter = firstLetter.substring(0, 1);

                    String leftLetter =
                        words[index].noun != null ? words[index].noun! : "";
                    leftLetter = leftLetter.substring(1, leftLetter.length);

                    String quoteDefault =
                        "Think of all the beauty still left around you and be happy.";
                    String quote = words[index].quote != null
                        ? words[index].quote!
                        : quoteDefault;

                    //bool isLiked = false;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                        color: AppColors.primaryColor,
                        elevation: 4,
                        child: InkWell(
                          onDoubleTap: () {
                            //String id = words[index].id!;
                            setState(() {
                              words[index].isFavorite =
                                  !words[index].isFavorite;
                            });
                          },
                          child: Container(
                              child: index >= 5
                                  ? InkWell(
                                      onTap: () {
                                        print('Show more');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => AllWordsPage(
                                                    words: words)));
                                      },
                                      child: Center(
                                        child: Container(
                                          child: Text('Show more...',
                                              style: AppStyles.h3.copyWith(
                                                  shadows: [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(3, 6),
                                                        blurRadius: 6)
                                                  ])),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        LikeButton(
                                          onTap: (bool isLiked) async {
                                            setState(() {
                                              words[index].isFavorite =
                                                  !words[index].isFavorite;
                                            });
                                            return words[index].isFavorite;
                                          },
                                          isLiked: words[index].isFavorite,
                                          padding: const EdgeInsets.all(16),
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          size: 42,
                                          circleColor: CircleColor(
                                              start: Color(0xff00ddff),
                                              end: Color(0xff0099cc)),
                                          bubblesColor: BubblesColor(
                                            dotPrimaryColor: Color(0xff33b5e5),
                                            dotSecondaryColor:
                                                Color(0xff0099cc),
                                          ),
                                          likeBuilder: (bool isLiked) {
                                            return ImageIcon(
                                              AssetImage(AppAssets.heart),
                                              color: isLiked
                                                  ? Colors.red
                                                  : Colors.white,
                                              size: 42,
                                            );
                                          },
                                        ),
                                        // Container(
                                        //     padding: const EdgeInsets.all(16),
                                        //     alignment: Alignment.centerRight,
                                        //     child: Image.asset(
                                        //       AppAssets.heart,
                                        //       color: words[index].isFavorite
                                        //           ? Colors.red
                                        //           : Colors.white,
                                        //     )),
                                        RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.start,
                                          text: TextSpan(
                                              text: firstLetter.toUpperCase(),
                                              style: TextStyle(
                                                  fontFamily: FontFamily.sen,
                                                  fontSize: 94,
                                                  fontWeight: FontWeight.bold,
                                                  shadows: [
                                                    BoxShadow(
                                                        color: Colors.black38,
                                                        offset: Offset(3, 6),
                                                        blurRadius: 6),
                                                  ]),
                                              children: [
                                                TextSpan(
                                                  text: leftLetter,
                                                  style: TextStyle(
                                                    fontFamily: FontFamily.sen,
                                                    fontSize: 62,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ]),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 40, left: 30, right: 50),
                                          child: AutoSizeText(
                                            '"$quote"',
                                            maxFontSize: 26,
                                            style: AppStyles.h4
                                                .copyWith(letterSpacing: 1),
                                          ),
                                        ),
                                      ],
                                    )),
                        ),
                      ),
                    );
                  },
                )),
            //indicator
            _currenIndex >= 6
                ? buildShowMore()
                : Container(
                    height: 12,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return buildIndicator(index == _currenIndex, size);
                        }),
                  )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          setState(() {
            getEnglishToday();
          });
        },
        child: Image.asset(AppAssets.exchange),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.lighBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 28, left: 18),
                child: Text(
                  'Your mind',
                  style: AppStyles.h3.copyWith(color: AppColors.textColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Appbutton(
                    label: "Favorites",
                    onTap: () {
                      _scafflodKey.currentState?.openDrawer();
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 36),
                child: Appbutton(
                    label: "Your Control",
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ControlPage()));
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildIndicator(bool isActive, Size size) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceInOut,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: isActive ? size.width * 1 / 5 : 24,
        decoration: BoxDecoration(
            color: isActive ? AppColors.lighBlue : AppColors.lightGrey,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black38, offset: Offset(2, 3), blurRadius: 3)
            ]));
  }

  Widget buildShowMore() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.centerLeft,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          elevation: 4,
          color: AppColors.primaryColor,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AllWordPage(
                            words: this.words,
                          )));
            },
            splashColor: Colors.black38,
            borderRadius: BorderRadius.all(Radius.circular(24)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'Show more',
                style: AppStyles.h5,
              ),
            ),
          ),
        ));
  }
}
