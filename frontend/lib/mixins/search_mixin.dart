import 'package:flutter/material.dart';
import 'package:geoponto/navigation/app_routes.dart';
import 'package:geoponto/screens/employee/home_screen.dart';
import 'package:geoponto/screens/employee/my_hr_screen.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  List<AppScreen> searchResults = [];
  bool showSearchResults = false;

  List<AppScreen> get allScreens => AppRoutes.all;
  List<AppScreen> get suggestionScreens => AppRoutes.suggestions;

  @override
  void initState() {
    super.initState();
    searchResults = suggestionScreens;
    searchController.addListener(onSearchChanged);
    searchFocusNode.addListener(onFocusChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    searchFocusNode.removeListener(onFocusChanged);
    searchFocusNode.dispose();
    super.dispose();
  }

  void onFocusChanged() {
    if (mounted) {
      setState(() {
        if (searchFocusNode.hasFocus) {
          if (searchController.text.isEmpty) {
            searchResults = suggestionScreens;
          }
          showSearchResults = true;
        } else {
          showSearchResults = false;
        }
      });
    }
  }

  void onSearchChanged() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          searchResults = suggestionScreens;
        });
      }
      return;
    }

    final results = allScreens.where((screen) {
      return screen.name.toLowerCase().contains(query);
    }).toList();

    if (mounted) {
      setState(() {
        searchResults = results;
      });
    }
  }

  PreferredSizeWidget buildSearchAppBar(BuildContext context, {bool automaticallyImplyLeading = true}) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            hintText: 'Pesquisar...',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget buildSearchResults(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4.0,
        child: Container(
          color: Colors.white,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final screen = searchResults[index];
              return ListTile(
                title: Text(screen.name),
                onTap: () {
                  searchFocusNode.unfocus();
                  searchController.clear();
                  
                  final currentRouteName = ModalRoute.of(context)?.settings.name;
                  if (currentRouteName != screen.name) {

                    bool isMainScreen = allScreens.any((s) => s.name == screen.name && (s.screenBuilder() is MyHrScreen || s.screenBuilder() is EmployeeHomeScreen));

                    if(isMainScreen && Navigator.canPop(context)){
                       Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => screen.screenBuilder(),
                          settings: RouteSettings(name: screen.name),
                        ),
                      );
                    } else {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => screen.screenBuilder(),
                          settings: RouteSettings(name: screen.name),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSearchableBody(BuildContext context, Widget body) {
     return Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (searchFocusNode.hasFocus) {
                searchFocusNode.unfocus();
              }
            },
            child: body,
          ),
          if (showSearchResults)
            buildSearchResults(context),
        ],
      );
  }
}