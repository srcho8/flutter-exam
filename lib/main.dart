import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'model/news.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<News> news;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('뉴스'),
        ),
        body: NewsPage(),
      ),
    );
  }

  Widget NewsPage() {
    return FutureBuilder<News>(
      future: fetchNews(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return NewsList(snapshot.data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        // 기본적으로 로딩 Spinner를 보여줍니다.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

// 서버로부터 데이터를 수신하여 그 결과를 List<Photo> 형태의 Future 객체로 반환하는 async 함수
Future<News> fetchNews(http.Client client) async {
  // 해당 URL로 데이터를 요청하고 수신함
  Uri uri = Uri.http('newsapi.org', '/v2/top-headlines', {'country': 'us'});

  final response = await client.get(
    uri,
    headers: {
      HttpHeaders.authorizationHeader: '679ab86ddbe443f094b617a88107a912'
    },
  );

  // parsePhotos 함수를 백그라운도 격리 처리
  return compute(parseNews, response.body);
}

// 수신한 데이터를 파싱하여 List<Photo> 형태로 반환
News parseNews(String responseBody) {
  Map<String, dynamic> a = jsonDecode(responseBody);

  // JSON Array를 List<Photo>로 변환하여 반환
  return News.fromJson(a);
}

// 수신된 그림들을 리스트뷰로 작성하여 출력하는 클래스
class NewsList extends StatelessWidget {
  final News news;

  NewsList(this.news);

  @override
  Widget build(BuildContext context) {
    // 리스뷰를 builder를 통해 생성. builder를 이용하면 화면이 스크롤 될 때 해당 앨리먼트가 랜더링 됨
    return ListView.builder(
      itemCount: news.articles.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: Column(
            children: [
              Image.network(news.articles[index].urlToImage),
              Container(
                child: Text(
                  news.articles[index].title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 20,),
                ),
                color: Colors.black87,
              ),
              Text(
                  news.articles[index].content == null ? "":news.articles[index].content
              ),
            ],
          ),
        );
      },
    );
  }
}
