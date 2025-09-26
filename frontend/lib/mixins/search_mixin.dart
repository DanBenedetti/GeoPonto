import 'package:flutter/material.dart';
import 'package:geoponto/navigation/app_routes.dart';

mixin SearchMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  List<SearchableScreen> searchResults = [];
  bool showSearchResults = false;

  List<SearchableScreen> get allScreens => AppRoutes.allScreens;
  List<SearchableScreen> get suggestionScreens => AppRoutes.suggestions;

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
      return screen.displayName.toLowerCase().contains(query);
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
                title: Text(screen.displayName),
                onTap: () {
                  searchFocusNode.unfocus();
                  searchController.clear();
                  
                  final currentRouteName = ModalRoute.of(context)?.settings.name;
                  if (currentRouteName != screen.routeName) {
                    if (screen.isMainScreen && Navigator.canPop(context)) {
                      Navigator.pushReplacementNamed(context, screen.routeName);
                    } else {
                      Navigator.pushNamed(context, screen.routeName);
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