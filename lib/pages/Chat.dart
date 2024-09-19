import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final SupabaseClient _client = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _getMessages();
    _subscribeToMessages();
  }

  void _getMessages() async {
    final response = await _client
        .from('messages')
        .select()
        .order('created_at', ascending: false);
    final data = response as List;
    setState(() {
      messages =
          data.map((message) => message as Map<String, dynamic>).toList();
    });
  }

  void _subscribeToMessages() {
    _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((snapshot) {
          setState(() {
            messages = snapshot.map((message) => message).toList();
            _scrollToBottom();
          });
        });
  }

  void _sendMessage(String content, {String? fileUrl}) async {
    if (content.isEmpty) return;

    final user = _client.auth.currentUser;
    if (user != null) {
      await _client.from('messages').insert({
        'user_id': user.id,
        'email': user.email,
        'content': content,
        'file_url': fileUrl,
      });
      _messageController.clear();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _uploadFile(File(image.path));
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      await _uploadFile(file);
    }
  }

  Future<void> _uploadFile(File file) async {
    final fileName = basename(file.path);
    final filePath = 'public/$fileName';

    try {
      final uploadedFilePath =
          await _client.storage.from('chat_files').upload(filePath, file);

      final fileUrl = _client.storage.from('chat_files').getPublicUrl(filePath);
      print('uploadedFilePath: $uploadedFilePath');
      print('fileUrl: $fileUrl');
      _sendMessage('img', fileUrl: fileUrl);
      _getMessages();
      _subscribeToMessages();
    } catch (e) {
      print('File upload error: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isFile = message['file_url'] != null;
                return ListTile(
                  title: isFile
                      ? GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(
                                    imageUrl: message['file_url']),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'To go back to the previous screen, click on image !')),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  const Text(
                                    '>> ',
                                  ),
                                  message['file_url'].endsWith('.png') ||
                                          message['file_url'].endsWith('.jpg')
                                      ? Image.network(
                                          message['file_url'],
                                          width: 100,
                                          height: 100,
                                        )
                                      : Text('File: ${message['file_url']}'),
                                ],
                              ),
                              Text(
                                'Email: ' + message['email'],
                              ),
                            ],
                          ),
                        )
                      : Text('${'>>    ' + message['content']}\nEmail: ' +
                          message['email']),
                  subtitle: Text('Date Time: ' + message['created_at']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickFile,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Enter a message',
                      ),
                      keyboardType: TextInputType.text,
                      onFieldSubmitted: (value) {},
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter a valid Message !';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final isValid = _formKey.currentState!.validate();
                      if (!isValid) {
                        return;
                      }
                      _formKey.currentState!.save();
                      _sendMessage(_messageController.text);
                      _getMessages();
                      _subscribeToMessages();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
