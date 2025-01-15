import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _mediaFile;
  final TextEditingController _captionController = TextEditingController();
  bool _isUploading = false;
  bool _isVideo = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _mediaFile = File(image.path);
          _isVideo = false;
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        setState(() {
          _mediaFile = File(video.path);
          _isVideo = true;
        });
      }
    } catch (e) {
      _showError('Error picking video: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _uploadPost() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    if (_mediaFile == null) {
      _showError('Please select an image or video');
      return;
    }

    if (_captionController.text.trim().isEmpty) {
      _showError('Please write a caption');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a unique filename
      final String fileName =
          '${const Uuid().v4()}.${_isVideo ? 'mp4' : 'jpg'}';
      final String path = 'posts/${user.uid}/$fileName';

      // Create storage reference
      final Reference storageRef = _storage.ref().child(path);

      // Upload media file
      final UploadTask uploadTask = storageRef.putFile(
        _mediaFile!,
        SettableMetadata(
          contentType: _isVideo ? 'video/mp4' : 'image/jpeg',
        ),
      );

      // Wait for upload to complete and get download URL
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final String username = userDoc.data()?['username'] ?? 'Usuario';
      final String userPhotoUrl = userDoc.data()?['photoUrl'] ?? '';

      // Create post document
      await _firestore.collection('posts').add({
        'userId': user.uid,
        'username': username,
        'userPhotoUrl': userPhotoUrl,
        'mediaUrl': downloadUrl,
        'caption': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
        'isVideo': _isVideo,
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error uploading post: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Publicación',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isUploading ? null : _uploadPost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mediaFile != null) ...[
              if (_isVideo)
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(
                      Icons.video_file,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                Image.file(
                  _mediaFile!,
                  fit: BoxFit.cover,
                  height: 300,
                ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Imagen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Escribe una descripción...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
          ],
        ),
      ),
    );
  }
}
