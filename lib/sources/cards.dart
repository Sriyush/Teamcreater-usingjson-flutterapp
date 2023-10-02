import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VideoCards extends StatefulWidget {
  final Map<String, dynamic> userData;
  final ValueChanged<bool> onSelected;

  VideoCards({required this.userData, required this.onSelected});

  @override
  _VideoCardsState createState() => _VideoCardsState();
}

class _VideoCardsState extends State<VideoCards> {
  late bool isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = false;
  }

  Future<ImageProvider> _loadNetworkImageWithRetry(String imageUrl,
      {int maxRetries = 3}) async {
    int retryCount = 0;
    int delaySeconds = 2; // Initial delay in seconds
    while (retryCount < maxRetries) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          return MemoryImage(response.bodyBytes);
        } else {
          print("Failed to load image - HTTP status code: ${response.statusCode}");
        }
      } catch (e) {
        print("Error loading image from $imageUrl: $e");
      }
      retryCount++;
      // Implement exponential backoff by doubling the delay
      delaySeconds *= 2;
      await Future.delayed(Duration(seconds: delaySeconds));
    }
    // Replace with your placeholder image
    return AssetImage('assets/placeholder_image.png');
  }

 Widget _buildAvailabilityIcon(bool available) {
  return GestureDetector(
    onTap: () {
      if (available) {
        setState(() {
          isSelected = !isSelected;
          widget.onSelected(isSelected);
        });
      } else {
        // Show a Snackbar if the profile is not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("This person is not available."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    },
    child: Icon(
      available ? Icons.check_circle : Icons.cancel,
      color: available ? Colors.green : Colors.red,
      size: 20,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = widget.userData;
    bool isAvailable = userData['available'] ?? false;

    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
        color: isSelected ? Colors.blueAccent : Colors.grey,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<ImageProvider>(
                  future: _loadNetworkImageWithRetry(userData['avatar']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return CircleAvatar(
                        backgroundImage: snapshot.data,
                        radius: 24,
                        backgroundColor: Colors.grey.shade100,
                      );
                    } else if (snapshot.hasError) {
                      // Handle image loading error here
                      print("Image loading error: ${snapshot.error}");
                      return Icon(Icons.error); // You can use an error icon or placeholder image.
                    } else {
                      // You can return a loading indicator here
                      return CircularProgressIndicator();
                    }
                  },
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    "${userData['first_name']} ${userData['last_name']} (id= ${userData['id']})",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'lexend',
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      overflow: TextOverflow.ellipsis,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Text(
              userData['email'],
              style: TextStyle(
                fontFamily: 'lexend',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
            ),
            SizedBox(height: 4),
            Text(
              userData['domain'],
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'lexend',
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 4),
            Text(
              userData['gender'],
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'lexend',
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "Available: ",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'lexend',
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                ),
                _buildAvailabilityIcon(isAvailable),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isSelected = !isSelected;
                  widget.onSelected(isSelected);
                });
              },
              child: Text(isSelected ? 'Selected' : 'Select'),
            ),
          ],
        ),
      ),
    );
  }
}
