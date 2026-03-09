import 'package:flutter/material.dart';
import 'package:frontend/services/menu_service.dart';
import 'menu_detail.dart';

class MenuPage extends StatefulWidget {
  final dynamic restaurant;

  const MenuPage({super.key, required this.restaurant});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<dynamic>> menus;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();
  bool showAllMenu = false;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    menus = MenuService().allMenu(widget.restaurant['id']);
  }

  @override
  void dispose() {
    searchController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  String getCategoryDisplay(String? category) {
    const categoryMap = {
      'main_course': 'Main course',
      'drink': 'Drink',
      'dessert': 'Dessert',
    };
    return categoryMap[category] ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant['name_res'] ?? 'Menu'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: menus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final allMenus = snapshot.data ?? [];
          final query = searchController.text.toLowerCase();
          final minPrice = double.tryParse(minPriceController.text);
          final maxPrice = double.tryParse(maxPriceController.text);

          final filteredMenus = allMenus.where((menu) {
            final name = (menu['name_menu'] ?? '').toString().toLowerCase();
            final matchesSearch = query.isEmpty || name.contains(query);
            final matchesStatus =
                showAllMenu || menu['status_menu'] == 'on_sale';

            final menuCategory = (menu['category'] ?? '').toString();
            final matchesCategory =
                selectedCategory == null || menuCategory == selectedCategory;

            final price =
                double.tryParse(menu['price']?.toString() ?? '0') ?? 0;
            final matchesMinPrice = minPrice == null || price >= minPrice;
            final matchesMaxPrice = maxPrice == null || price <= maxPrice;

            return matchesSearch &&
                matchesStatus &&
                matchesCategory &&
                matchesMinPrice &&
                matchesMaxPrice;
          }).toList();

          const categoryPriority = {'main_course': 0, 'dessert': 1, 'drink': 2};

          filteredMenus.sort((a, b) {
            final aCategory = (a['category'] ?? '').toString();
            final bCategory = (b['category'] ?? '').toString();
            final aOrder = categoryPriority[aCategory] ?? 999;
            final bOrder = categoryPriority[bCategory] ?? 999;
            return aOrder.compareTo(bOrder);
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search menu...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () => _showFilterDialog(context),
                      icon: Badge(
                        isLabelVisible:
                            selectedCategory != null ||
                            minPriceController.text.isNotEmpty ||
                            maxPriceController.text.isNotEmpty,
                        child: const Icon(Icons.filter_list),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: showAllMenu,
                      onChanged: (value) {
                        setState(() {
                          showAllMenu = value ?? false;
                        });
                      },
                    ),
                    const Text('Show all menu'),
                  ],
                ),
              ),
              Expanded(
                child: filteredMenus.isEmpty
                    ? const Center(child: Text('No menu found'))
                    : ListView.separated(
                        itemCount: filteredMenus.length,
                        itemBuilder: (context, index) {
                          final res = filteredMenus[index];
                          const String baseImageUrl = "http://10.0.2.2:5000/";
                          final String imagePath = res['img_url'].replaceAll(
                            "\\",
                            "/",
                          );
                          final String fullImageUrl = baseImageUrl + imagePath;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MenuDetailPage(
                                      menu: res,
                                      restaurant: widget.restaurant,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        fullImageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            res['name_menu'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            getCategoryDisplay(res['category']),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "${res['price']} baht",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            res['status_menu'] == 'on_sale'
                                                ? 'On sale'
                                                : res['status_menu'] ==
                                                      'soldout'
                                                ? 'Sold out'
                                                : 'N/A',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  res['status_menu'] ==
                                                      'on_sale'
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, int index) =>
                            const Divider(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    String? tempCategory = selectedCategory;
    final tempMinController = TextEditingController(
      text: minPriceController.text,
    );
    final tempMaxController = TextEditingController(
      text: maxPriceController.text,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Menu'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      value: tempCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('Select category'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(
                          value: 'main_course',
                          child: Text('Main Course'),
                        ),
                        DropdownMenuItem(
                          value: 'dessert',
                          child: Text('Dessert'),
                        ),
                        DropdownMenuItem(value: 'drink', child: Text('Drink')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Price Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tempMinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Min',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('-'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: tempMaxController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Max',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = null;
                      minPriceController.clear();
                      maxPriceController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = tempCategory;
                      minPriceController.text = tempMinController.text;
                      maxPriceController.text = tempMaxController.text;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
