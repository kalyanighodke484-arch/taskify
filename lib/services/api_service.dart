import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_manger/models/quotes_model.dart';

class ApiService {
  Future<QuoteModel>fetchQuotes() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/quotes/random'),
    );

    if(response.statusCode==200){
      final data =jsonDecode(response.body);
      return QuoteModel.fromJson(data);
    }else
      {
        throw Exception(
          "Failed to load quote",
        );
      }
  }
}
