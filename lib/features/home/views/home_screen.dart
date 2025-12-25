import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Make sure this is imported
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../main.dart'; 
import '../controllers/journal_controller.dart';
import 'add_journal_screen.dart';
import 'recycle_bin_screen.dart';
import 'weekly_analysis_screen.dart';
import 'widgets/journal_card.dart';
import 'widgets/mood_calendar.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JournalController _controller = JournalController();
  final TextEditingController _searchController = TextEditingController();
  
  // FIX: Access the ThemeController using Get.find()
  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    _controller.loadJournals();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are in dark mode to adjust UI colors
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 120, 
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
              iconTheme: IconThemeData(
                color: Theme.of(context).appBarTheme.iconTheme?.color ?? (isDarkMode ? Colors.white : Colors.black87)
              ),
              title: Text(
                'Embrace', 
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              actions: [
                 IconButton(
                  icon: const Icon(Icons.pie_chart_outline),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                       builder: (_) => WeeklyAnalysisScreen(controller: _controller))),
                ),
                 // UPDATED: Toggle theme using our found _themeController
                 IconButton(
                  icon: Icon(_themeController.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  onPressed: () { 
                    _themeController.toggleTheme(); 
                    setState((){}); // Refresh the local icon state
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleBinScreen()));
                    _controller.loadJournals(); 
                  },
                )
              ],
              bottom: TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: "Journal", icon: Icon(Icons.grid_view_rounded)),
                  Tab(text: "Mood Calendar", icon: Icon(Icons.calendar_month_rounded)),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // --- TAB 1: PINTEREST GRID ---
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                             color: Colors.black.withValues(alpha: 0.03), 
                             blurRadius: 10,
                             offset: const Offset(0, 4)
                           )
                        ]
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => _controller.search(value),
                        decoration: InputDecoration(
                          hintText: "Search memories...",
                          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        if (_controller.journals.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_note, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text("Your story begins here.", 
                                  style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              ],
                            ),
                          );
                        }
                        return MasonryGridView.count(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          crossAxisCount: 2, 
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          itemCount: _controller.journals.length,
                          itemBuilder: (context, index) {
                            final entry = _controller.journals[index];
                            return JournalCard(
                              entry: entry,
                              onTap: () async {
                                await Navigator.push(context, MaterialPageRoute(builder: (_) => 
                                  AddJournalScreen(controller: _controller, entry: entry)));
                                _controller.loadJournals();
                              },
                              onFavoriteToggle: () => _controller.toggleFavorite(entry),
                              onDelete: () => _controller.moveToBin(entry),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              // --- TAB 2: MOOD HEATMAP ---
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text("Your Emotional Journey", 
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                          )
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                               BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)
                            ]
                          ),
                          child: MoodCalendar(journals: _controller.journals),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode 
                  ? [const Color(0xFF9F8BFF), const Color(0xFF6B4EFF)] 
                  : [const Color(0xFF6B4EFF), const Color(0xFF9F8BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => AddJournalScreen(controller: _controller)));
              _controller.loadJournals();
            },
            label: const Text("Write", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            icon: const Icon(Icons.edit_rounded),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}