import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/activity_type_enums.dart';

import '../../colors.dart';
import '../empty_states/no_list_empty_state.dart';
import '../search_bar.dart';

class ActivitySelectorScreen extends StatefulWidget {
  final Function(ActivityType activity) onSelectActivity;

  const ActivitySelectorScreen({super.key, required this.onSelectActivity});

  @override
  State<ActivitySelectorScreen> createState() => _ActivitySelectorScreenState();
}

class _ActivitySelectorScreenState extends State<ActivitySelectorScreen> {
  late TextEditingController _searchController;

  List<ActivityType> _activities = [];
  List<ActivityType> _filteredActivities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
        title: Text("Select An Activity".toUpperCase(),
            style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            children: [
              CSearchBar(
                  hintText: "Search for activity",
                  onChanged: _runSearch,
                  onClear: _clearSearch,
                  controller: _searchController),
              const SizedBox(height: 10),
              _filteredActivities.isNotEmpty
                  ? Expanded(
                      child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListView.separated(
                        itemCount: _filteredActivities.length,
                        itemBuilder: (context, index) {
                          final image = _filteredActivities[index].image;
                          return ListTile(
                            leading: image != null ? Image.asset(
                              'icons/$image.png',
                              fit: BoxFit.contain,
                              height: 24, // Adjust the height as needed
                            ) : Icon(
                              _filteredActivities[index].icon,
                              color: Colors.white,
                            ), // Placeholder icon
                            title: Text(_filteredActivities[index].name.toUpperCase(),
                                style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400)),
                            onTap: () {
                              widget.onSelectActivity(_filteredActivities[index]);
                              Navigator.pop(context);
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(
                            height: 0.1,
                            color: sapphireLighter,
                          ),
                        ),
                      ),
                    ))
                  : NoListEmptyState(message: 'We don\'t have "${_searchController.text} activity')
            ],
          ),
        ),
      ),
    );
  }

  void _runSearch(String? _) {
    final query = _searchController.text.toLowerCase().trim();

    List<ActivityType> searchResults = [];

    searchResults = _activities.where((activity) => activity.name.toLowerCase().contains(query.toLowerCase())).toList();

    searchResults.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _filteredActivities = searchResults;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _runSearch("");
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _activities = ActivityType.values.sorted((a, b) => a.name.compareTo(b.name));
    _filteredActivities = _activities;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
