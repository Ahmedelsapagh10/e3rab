import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/core/exports.dart';
import 'package:new_strucuture/features/main_screen/cubit/cubit.dart';
import 'package:new_strucuture/features/main_screen/cubit/state.dart';
import 'package:new_strucuture/config/themes/theme_cubit.dart';
import 'package:new_strucuture/config/themes/theme_helper.dart';
import 'package:new_strucuture/core/utils/restart_app_class.dart';
import '../data/model/product_model.dart';
import '../widget/horizontal_product_card.dart';
import '../widget/staggered_product_card.dart';
import '../widget/product_details_sheet.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    "electronics",
    "jewelery",
    "men's clothing",
    "women's clothing",
  ];

  @override
  void initState() {
    super.initState();
    // Fetch products on load
    context.read<MainCubit>().getProductsList();
  }

  String categoryKey(String cat) {
    if (cat.toLowerCase() == 'all') return 'all';
    return cat.toLowerCase().replaceAll("'", "").replaceAll(" ", "_");
  }

  void _showProductDetails(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailsSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width > 800
        ? 64.0
        : 16.0;
    final colors = ThemeHelper.colorsOf(context);
    final isDark = ThemeHelper.isDarkMode(context);

    return Scaffold(
      backgroundColor: colors.background2,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                ImageAssets.appIconWithoutBG,
                height: 36,
                width: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'app_name'.tr(),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher Toggle
          TextButton(
            onPressed: () async {
              if (context.locale.languageCode == 'ar') {
                await context.setLocale(const Locale('en', ''));
              } else {
                await context.setLocale(const Locale('ar', ''));
              }
              if (context.mounted) {
                HotRestartController.performHotRestart(context);
              }
            },
            child: Text(
              context.locale.languageCode == 'ar' ? 'EN' : 'عربي',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Theme Switcher Toggle Icon
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme(context);
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: colors.borderColor, height: 1),
        ),
      ),
      body: BlocBuilder<MainCubit, MainState>(
        builder: (context, state) {
          if (state is MainLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is MainError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'load_failed'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.read<MainCubit>().getProductsList(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text('try_again'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is MainLoaded) {
            final allProducts = state.products;

            // Apply local category filter
            final filteredProducts = _selectedCategory == 'All'
                ? allProducts
                : allProducts
                      .where(
                        (p) =>
                            p.category.toLowerCase() ==
                            _selectedCategory.toLowerCase(),
                      )
                      .toList();

            // Trending products (for horizontal view - take first 5 from the selected list)
            final trendingProducts = filteredProducts.take(5).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter Chips
                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected =
                            _selectedCategory.toLowerCase() ==
                            cat.toLowerCase();
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.fixedPrimary
                                  : colors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? colors.fixedPrimary
                                    : colors.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                cat.toLowerCase() == 'all'
                                    ? 'all'.tr()
                                    : categoryKey(cat).tr(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                            ? Colors.white70
                                            : AppColors.text),
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. HORIZONTAL LIST (Trending Deals)
                  if (trendingProducts.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'trending_deals'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black,
                            ),
                          ),
                          Text(
                            'see_all'.tr(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        itemCount: trendingProducts.length,
                        itemBuilder: (context, index) {
                          final product = trendingProducts[index];
                          return HorizontalProductCard(
                            product: product,
                            onTap: () => _showProductDetails(context, product),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // 2. VERTICAL STAGGERED LIST (All Products Catalog using SliverStairedGridDelegate)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Text(
                      'exclusive_catalog'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  filteredProducts.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'no_products'.tr(),
                              style: const TextStyle(
                                color: AppColors.hint,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: MasonryGridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 4 : 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return StaggeredProductCard(
                                product: product,
                                index: index,
                                onTap: () =>
                                    _showProductDetails(context, product),
                              );
                            },
                          ),
                        ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
