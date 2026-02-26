import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:schedule_generator_ai/models/task.dart';

// jembatan antar penghubung client dan server
class GeminiService {
  static const String _baseURL = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";
  final String apiKey; 

  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "Please input your API KEY" {
    if (apiKey.isEmpty) {
      throw ArgumentError("API KEY is missing");
    }
  }
  
  Future<String> generateSchedule(List<Task> tasks) async {
    _validateTasks(tasks);
    final prompt = _buildPrompt(tasks);
    try {
      // ini nanti akan muncul di debug console
      print("Prompt: \n$prompt");
      // add request time out message to avoid indefinite hangs if the API doesn't response
      final response = await http
      // response itu di hadirkan karena AI sudah selesai mikir
          .post(Uri.parse("$_baseURL?key=$apiKey"), headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "contents":[
              {
                "role": "user",
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          })
          // ini time out biar requestnya gak kelamaan, best practicenya emang 20 detik biar gak kelamaan dan kecepetan
          ).timeout(Duration(seconds: 20));
          return _handleResponse(response);
      // sebuah code yg letak nya setelah await itu hasil yg akan di generate setelah proses async selesai.
    } catch (e) {
      throw ArgumentError("Failed to generate schedule: $e");
    }
  }
  String _handleResponse(http.Response responses) {
    final data = jsonDecode(responses.body);
    if(responses.statusCode == 401){
      throw ArgumentError("inValid api key or unautorized");
    } else if (responses.statusCode == 429) {
      throw ArgumentError("Rate limit exceeded");
    } else if(responses.statusCode == 500){
      throw ArgumentError("internal server error");
    } else if (responses.statusCode == 503){
      throw ArgumentError("service unavailable");
    } else if(responses.statusCode == 200){
      return data["candidates"][0]["content"]["parts"][0]["text"];
    }else{
      throw ArgumentError("Unknown Error");
    }
  }
  String _buildPrompt(List<Task> tasks) {
    final tasksList = tasks.map((task) => "${task.name} (Priority: ${task.priority}, Duration: ${task.duration}, Deadline: ${task.deadline})").join("\n");
    return "Buatkan jadwal harian yang optimal berdasarkan task berikut:\n$tasksList";
  }

  void _validateTasks(List<Task> tasks) {
    if (tasks.isEmpty) throw ArgumentError("Tasks cannot be empty. PLease insert ur prompt");
  }
}