import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../models/cart.dart';
import '../../models/category.dart';
import '../../models/notification.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/common/login_dialog.dart';

/// A reusable top bar widget with logo, search, and profile icon
class TopBar extends ConsumerStatefulWidget {
  const TopBar({super.key});

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCart = ref.watch(cartProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenWidth < 600;

    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Colors.white,
      toolbarHeight: isMobile ? 64 : 72,
      titleSpacing: 0,
      title: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.only(
          left: isMobile ? (isSmallMobile ? 12 : 16) : 48,
          right: isMobile ? 4 : 8,
        ),
        width: double.infinity,
        child: Row(
          children: [
            // Logo with sky icon and text - always on the left
            Padding(
              padding: EdgeInsets.only(right: isMobile ? 8 : 32),
              child: InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: isMobile ? 36 : 40,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallMobile ? 8 : 12,
                    vertical: isMobile ? 6 : 0,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A9FCC), Color(0xFF5BB7E0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/sky.svg',
                        width: isMobile ? 20 : 24,
                        height: isMobile ? 20 : 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      if (!isSmallMobile) ...[
                        SizedBox(width: isMobile ? 6 : 8),
                        Text(
                          isMobile
                              ? AppConstants.appName.toUpperCase().substring(0, 4)
                              : AppConstants.appName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: isMobile ? 0.8 : 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Desktop: Search bar + Menu items
            if (!isMobile) ...[
              // Search bar - takes all available space
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 0, right: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un événement, un vendeur, un produit...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/images/search.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            Colors.grey[600]!,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4A9FCC), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.go('/search?q=${Uri.encodeComponent(value)}');
                      }
                    },
                  ),
                ),
              ),
              // Menu items and action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavButton(
                    label: 'Accueil',
                    isActive: false,
                    onTap: () => context.go('/'),
                  ),
                  _CategoriesDropdown(),
                  _NavButton(
                    label: 'Événements',
                    onTap: () => context.go('/'),
                  ),
                  _NavButton(
                    label: 'Mes commandes',
                    onTap: () => context.go('/orders'),
                  ),
                  const SizedBox(width: 16),
                  _NotificationsDropdown(),
                  const SizedBox(width: 8),
                  _CartIcon(cart: asyncCart),
                  const SizedBox(width: 8),
                  _ProfileIcon(),
                ],
              ),
            ]
            // Mobile: All icons pushed to the right
            else ...[
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search icon
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.grey[700], size: 20),
                    onPressed: () => context.go('/search'),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Notifications
                  _NotificationsDropdown(isMobile: true),
                  const SizedBox(width: 4),
                  // Cart icon
                  _CartIcon(cart: asyncCart, isMobile: true),
                  const SizedBox(width: 4),
                  // Profile icon
                  _ProfileIcon(isMobile: true),
                  const SizedBox(width: 4),
                  // Menu drawer button
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.grey[700], size: 22),
                    onPressed: () => _showMobileMenu(context),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _MobileMenuItem(
                      icon: Icons.home_outlined,
                      label: 'Accueil',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/');
                      },
                    ),
                    _MobileMenuItem(
                      icon: Icons.category_outlined,
                      label: 'Catégories',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/categories');
                      },
                    ),
                    _MobileMenuItem(
                      icon: Icons.play_circle_outline,
                      label: 'Événements',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/');
                      },
                    ),
                    _MobileMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Mes commandes',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/orders');
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 12),
                    _MobileMenuItem(
                      icon: Icons.person_outline,
                      label: 'Profil',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/profile');
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isActive ? const Color(0xFF4A9FCC) : Colors.grey[700],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CategoriesDropdown extends ConsumerStatefulWidget {
  const _CategoriesDropdown();

  @override
  ConsumerState<_CategoriesDropdown> createState() =>
      _CategoriesDropdownState();
}

class _CategoriesDropdownState extends ConsumerState<_CategoriesDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isHovered = false;

  void _showDropdown(List<Category> categories) {
    if (_overlayEntry != null) return;
    
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final buttonPosition = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final buttonWidth = renderBox?.size.width ?? 0;
    final dropdownWidth = 240.0;
    
    // Calculate position to ensure dropdown doesn't go beyond screen
    double leftOffset = 0;
    if (buttonPosition.dx + dropdownWidth > screenWidth) {
      // If dropdown would overflow, align it to the right edge of the button
      leftOffset = buttonWidth - dropdownWidth;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: buttonPosition.dx + leftOffset,
        top: buttonPosition.dy + 12,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: MouseRegion(
            onEnter: (_) => _isHovered = true,
            onExit: (_) {
              _isHovered = false;
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!_isHovered) {
                  _hideDropdown();
                }
              });
            },
            child: Container(
              width: dropdownWidth,
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4), // Reduced padding
                children: categories.map((category) {
                String svgPath;
                switch (category.name) {
                  case 'Mode':
                    svgPath = 'assets/images/mode.svg';
                    break;
                  case 'Beauté':
                    svgPath = 'assets/images/beauty.svg';
                    break;
                  case 'Électronique':
                    svgPath = 'assets/images/electronics.svg';
                    break;
                  case 'Maison':
                    svgPath = 'assets/images/home.svg';
                    break;
                  case 'Sport':
                    svgPath = 'assets/images/sport.svg';
                    break;
                  default:
                    svgPath = 'assets/images/mode.svg';
                }

                return InkWell(
                  onTap: () {
                    _hideDropdown();
                    context.go('/category/${category.slug}');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced padding
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          svgPath,
                          width: 20, // Slightly smaller icon
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF4A9FCC),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10), // Reduced spacing
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14, // Slightly smaller font
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isHovered = false;
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoriesProvider);

    return CompositedTransformTarget(
      link: _layerLink,
      child: asyncCategories.when(
        data: (categories) {
          return MouseRegion(
            onEnter: (_) {
              _isHovered = true;
              _showDropdown(categories);
            },
            onExit: (_) {
              _isHovered = false;
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!_isHovered) {
                  _hideDropdown();
                }
              });
            },
            child: _NavButton(
              label: 'Catégories',
              onTap: () => context.go('/categories'),
            ),
          );
        },
        loading: () => _NavButton(
          label: 'Catégories',
          onTap: () {},
        ),
        error: (_, __) => _NavButton(
          label: 'Catégories',
          onTap: () {},
        ),
      ),
    );
  }
}

class _CartIcon extends ConsumerWidget {
  final AsyncValue<Cart> cart;
  final bool isMobile;

  const _CartIcon({
    required this.cart,
    this.isMobile = false,
  });

  Future<void> _handleCartTap(BuildContext context, WidgetRef ref) async {
    final isLoggedIn = ref.read(isLoggedInProvider);
    
    if (!isLoggedIn) {
      // Show login dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const LoginDialog(),
      );
      
      if (result == true && context.mounted) {
        // User logged in, refresh the UI and navigate to cart
        ref.invalidate(currentUserProvider);
        context.go('/cart');
      }
    } else {
      // Navigate to cart
      context.go('/cart');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.shopping_cart_outlined,
              size: isMobile ? 20 : 22,
            ),
            onPressed: () => _handleCartTap(context, ref),
            color: Colors.grey[700],
            padding: isMobile ? const EdgeInsets.all(8) : null,
            constraints: isMobile
                ? const BoxConstraints(minWidth: 36, minHeight: 36)
                : null,
          ),
        ),
        cart.when(
          data: (cartData) {
            final count = cartData.items.length;
            if (count == 0) return const SizedBox.shrink();
            return Positioned(
              right: isMobile ? 6 : 8,
              top: isMobile ? 6 : 8,
              child: Container(
                padding: EdgeInsets.all(isMobile ? 3 : 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A9FCC),
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: isMobile ? 14 : 16,
                  minHeight: isMobile ? 14 : 16,
                ),
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ProfileIcon extends ConsumerStatefulWidget {
  final bool isMobile;

  const _ProfileIcon({this.isMobile = false});

  @override
  ConsumerState<_ProfileIcon> createState() => _ProfileIconState();
}

class _ProfileIconState extends ConsumerState<_ProfileIcon> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isHovered = false;

  Future<void> _handleProfileTap() async {
    final isLoggedIn = ref.read(isLoggedInProvider);
    
    if (!isLoggedIn) {
      // Show login dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const LoginDialog(),
      );
      
      if (result == true && mounted) {
        // User logged in, refresh UI
        ref.invalidate(currentUserProvider);
      }
    } else {
      // Show dropdown
      _showDropdown();
    }
  }

  void _showDropdown() {
    if (_overlayEntry != null) return;
    
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final buttonPosition = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final buttonWidth = renderBox?.size.width ?? 0;
    final dropdownWidth = 280.0;
    
    // Calculate position to align right edge with button, but ensure it doesn't go beyond screen
    double leftOffset = buttonWidth - dropdownWidth;
    if (buttonPosition.dx + leftOffset < 0) {
      // If dropdown would overflow on the left, align it to the left edge of the button
      leftOffset = 0;
    }
    // Also ensure it doesn't go beyond right edge
    if (buttonPosition.dx + leftOffset + dropdownWidth > screenWidth) {
      leftOffset = screenWidth - buttonPosition.dx - dropdownWidth;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: buttonPosition.dx + leftOffset,
        top: buttonPosition.dy + 12,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: MouseRegion(
            onEnter: (_) => _isHovered = true,
            onExit: (_) {
              _isHovered = false;
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!_isHovered) {
                  _hideDropdown();
                }
              });
            },
            child: Container(
              width: dropdownWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User info section
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentUser.avatar,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentUser.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Logout button
                  InkWell(
                    onTap: () {
                      _hideDropdown();
                      _handleLogout();
                    },
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 20,
                            color: Colors.red[600],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isHovered = false;
  }

  void _handleLogout() {
    final authService = ref.read(authServiceProvider);
    authService.logout();
    ref.invalidate(currentUserProvider);
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isLoggedIn = currentUser != null;

    final profileWidget = Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(widget.isMobile ? 8 : 12),
      ),
      child: IconButton(
        icon: isLoggedIn && currentUser.avatar.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(widget.isMobile ? 6 : 8),
                child: Image.network(
                  currentUser.avatar,
                  width: widget.isMobile ? 20 : 22,
                  height: widget.isMobile ? 20 : 22,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                    'assets/images/Profile.svg',
                    width: widget.isMobile ? 20 : 22,
                    height: widget.isMobile ? 20 : 22,
                    colorFilter: ColorFilter.mode(
                      Colors.grey[700]!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              )
            : SvgPicture.asset(
                'assets/images/Profile.svg',
                width: widget.isMobile ? 20 : 22,
                height: widget.isMobile ? 20 : 22,
                colorFilter: ColorFilter.mode(
                  Colors.grey[700]!,
                  BlendMode.srcIn,
                ),
              ),
        onPressed: _handleProfileTap,
        padding: widget.isMobile ? const EdgeInsets.all(8) : null,
        constraints: widget.isMobile
            ? const BoxConstraints(minWidth: 36, minHeight: 36)
            : null,
      ),
    );

    if (isLoggedIn && !widget.isMobile) {
      // Desktop: Show dropdown on hover
      return CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) {
            _isHovered = true;
            _showDropdown();
          },
          onExit: (_) {
            _isHovered = false;
            Future.delayed(const Duration(milliseconds: 200), () {
              if (!_isHovered) {
                _hideDropdown();
              }
            });
          },
          child: profileWidget,
        ),
      );
    } else {
      // Mobile or not logged in: Show on tap
      return profileWidget;
    }
  }
}

class _MobileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9FCC).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4A9FCC),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsDropdown extends ConsumerStatefulWidget {
  final bool isMobile;

  const _NotificationsDropdown({this.isMobile = false});

  @override
  ConsumerState<_NotificationsDropdown> createState() =>
      _NotificationsDropdownState();
}

class _NotificationsDropdownState extends ConsumerState<_NotificationsDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isHovered = false;

  void _showDropdown(List<AppNotification> notifications) {
    if (_overlayEntry != null) return;
    
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final buttonPosition = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final buttonWidth = renderBox?.size.width ?? 0;
    final dropdownWidth = 400.0;
    
    // Calculate position to align right edge with button, but ensure it doesn't go beyond screen
    double leftOffset = buttonWidth - dropdownWidth;
    if (buttonPosition.dx + leftOffset < 0) {
      // If dropdown would overflow on the left, align it to the left edge of the button
      leftOffset = 0;
    }
    // Also ensure it doesn't go beyond right edge
    if (buttonPosition.dx + leftOffset + dropdownWidth > screenWidth) {
      leftOffset = screenWidth - buttonPosition.dx - dropdownWidth;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: buttonPosition.dx + leftOffset,
        top: buttonPosition.dy + 4,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: MouseRegion(
            onEnter: (_) => _isHovered = true,
            onExit: (_) {
              _isHovered = false;
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!_isHovered) {
                  _hideDropdown();
                }
              });
            },
            child: Container(
              width: dropdownWidth,
              constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _hideDropdown();
                            context.go('/notifications');
                          },
                          child: const Text('Voir tout'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                  child: notifications.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Aucune notification',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          children: notifications.take(5).map((notification) {
                            IconData iconData;
                            Color iconColor;

                            switch (notification.type) {
                              case 'new_order':
                                iconData = Icons.shopping_bag;
                                iconColor = const Color(0xFF4A9FCC);
                                break;
                              case 'product_featured':
                                iconData = Icons.star;
                                iconColor = const Color(0xFFF59E0B);
                                break;
                              case 'live_event_starting':
                                iconData = Icons.play_circle;
                                iconColor = const Color(0xFFEF4444);
                                break;
                              default:
                                iconData = Icons.notifications;
                                iconColor = Colors.grey;
                            }

                            return InkWell(
                              onTap: () {
                                _hideDropdown();
                                context.go('/notifications');
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: notification.read
                                      ? Colors.transparent
                                      : const Color(0xFFF0F9FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: iconColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        iconData,
                                        size: 20,
                                        color: iconColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: notification.read
                                                  ? FontWeight.w500
                                                  : FontWeight.w600,
                                              color: const Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notification.message,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!notification.read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF4A9FCC),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncNotifications = ref.watch(notificationsProvider);
    final asyncUnreadCount = ref.watch(unreadNotificationsCountProvider);

    return CompositedTransformTarget(
      link: _layerLink,
      child: asyncNotifications.when(
        data: (notifications) {
          return MouseRegion(
            onEnter: (_) {
              _isHovered = true;
              _showDropdown(notifications);
            },
            onExit: (_) {
              _isHovered = false;
              Future.delayed(const Duration(milliseconds: 200), () {
                if (!_isHovered) {
                  _hideDropdown();
                }
              });
            },
            child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: widget.isMobile ? 20 : 22,
                  ),
                  onPressed: () => context.go('/notifications'),
                  color: Colors.grey[700],
                  padding: widget.isMobile ? const EdgeInsets.all(8) : null,
                  constraints: widget.isMobile
                      ? const BoxConstraints(minWidth: 36, minHeight: 36)
                      : null,
                ),
              ),
              asyncUnreadCount.when(
                data: (count) {
                  if (count == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
        },
        loading: () => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () => context.go('/notifications'),
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        error: (_, __) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                onPressed: () => context.go('/notifications'),
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
