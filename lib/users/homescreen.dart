import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heliverse/sources/cards.dart';
import 'package:heliverse/users/teamscreen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  int currentPage = 0;
  late PageController pageController;

  bool isAvailableFilter = false;
  String selectedGenderFilter = "All";
  String selectedDomainFilter = "All";
  List<Map<String, dynamic>> selectedUsersForTeam = [];
  List<Map<String, dynamic>> teamsData = [];

  List<String> genderOptions = ["All", "Male", "Female"];
  List<String> domainOptions = ["All", "Marketing", "IT", "Sales", "Finance"];

  void _filterData(String query) {
    print("Filtering with query: $query");
    if (query.isEmpty) {
      setState(() {
        filteredData = List<Map<String, dynamic>>.from(userDataList);
      });
    } else {
      setState(() {
        filteredData = userDataList.where((userData) {
          final fullName =
              "${userData['first_name']} ${userData['last_name']}"
                  .toString()
                  .toLowerCase();
          return fullName.contains(query.toLowerCase());
        }).toList();
      });
    }
    filteredData = filteredData.where((userData) {
      final bool available = userData['available'] ?? false;
      final String gender = userData['gender'] ?? "";
      final String domain = userData['domain'] ?? "";
      return (!isAvailableFilter || available) &&
          (selectedGenderFilter == "All" || gender == selectedGenderFilter) &&
          (selectedDomainFilter == "All" || domain == selectedDomainFilter);
    }).toList();
  }

  late List<Map<String, dynamic>> userDataList = [];
  bool isLoading = true;
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    // Load user data from the JSON asset
    _loadUserData();
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final String jsonStr =
          await rootBundle.loadString('assets/heliverse_mock_data.json');
      final List<dynamic> data = json.decode(jsonStr);
      setState(() {
        userDataList = List<Map<String, dynamic>>.from(data);
        filteredData = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      print("Error loading JSON data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateFilters() {
    setState(() {
      _filterData(_searchController.text);
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Heliverse",
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontFamily: 'lexend',
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _showCannotGoBackSnackbar();
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 1),
              height: 50,
              width: MediaQuery.of(context).size.width / 1.1,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterData(value);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search Profile...',
                        hintStyle: TextStyle(
                          fontFamily: 'lexend',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.black),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Select Gender"),
                    SizedBox(
                      width: 4,
                    ),
                    DropdownButton<String>(
                      value: selectedGenderFilter,
                      onChanged: (newValue) {
                        setState(() {
                          selectedGenderFilter = newValue!;
                          _updateFilters();
                        });
                      },
                      items: genderOptions.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      hint: Text("Select Gender Filter"),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Select Department'),
                    SizedBox(
                      width: 4,
                    ),
                    DropdownButton<String>(
                      value: selectedDomainFilter,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDomainFilter = newValue!;
                          _updateFilters();
                        });
                      },
                      items: domainOptions.map((domain) {
                        return DropdownMenuItem<String>(
                          value: domain,
                          child: Text(domain),
                        );
                      }).toList(),
                      hint: Text("Select Domain Filter"),
                    ),
                  ],
                ),
                CheckboxListTile(
                  title: Text("Available"),
                  value: isAvailableFilter,
                  onChanged: (newValue) {
                    setState(() {
                      isAvailableFilter = newValue!;
                      _updateFilters();
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      controller: pageController,
                      itemCount: (filteredData.length / 10).ceil(),
                      onPageChanged: (int page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      itemBuilder: (context, page) {
                        final startIndex = page * 10;
                        final endIndex = startIndex + 10;
                        final pageData = filteredData.sublist(
                          startIndex,
                          endIndex > filteredData.length
                              ? filteredData.length
                              : endIndex,
                        );

                        return SingleChildScrollView(
                          child: Column(
                            children: pageData.map((userData) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8),
                                child: VideoCards(
                                  userData: userData,
                                  onSelected: (isSelected) {
                                    setState(() {
                                      if (isSelected) {
                                        selectedUsers.add(userData);
                                      } else {
                                        selectedUsers.remove(userData);
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
            // buildPageIndicators(),
            ElevatedButton(
  onPressed: () {
    // Filter selected users by unique domain and availability
    final Map<String, List<Map<String, dynamic>>> usersByDomain = {};

    for (final user in selectedUsers) {
      final domain = user['domain'];
      final available = user['available'] ?? false;

      if (available) {
        if (!usersByDomain.containsKey(domain)) {
          usersByDomain[domain] = [];
        }
        usersByDomain[domain]!.add(user);
      }
    }

    // Create a list of teams as Map<String, dynamic> objects
    final List<Map<String, dynamic>> teams = usersByDomain.entries.map((entry) {
      final domain = entry.key;
      final members = entry.value;
      return {
        'teamName': domain,
        'members': members,
      };
    }).toList();

    // Add teams to teamsData
    teamsData.addAll(teams);

    // Clear the selectedUsers list
    selectedUsers.clear();

    // Navigate to the TeamScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamScreen(teams: teamsData),
      ),
    );
  },
  child: Text("Add To Team"),
)

          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){},
          child: Icon(Icons.group),
        ),
      ),
      
    );
  }

  Widget buildPageIndicators() {
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(
          (filteredData.length / 10).ceil(),
          (index) => buildPageIndicator(index),
        ),
      ),
    );
  }

  Widget buildPageIndicator(int pageIndex) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pageIndex == currentPage ? Colors.blue : Colors.grey,
      ),
    );
  }

  void _showCannotGoBackSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You can't go back at this stage."),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class ShimmerVideoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: Duration(seconds: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 200.0,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                width: 100.0,
                height: 10.0,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                width: 50.0,
                height: 10.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
