import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class FloatingNavbar extends StatelessWidget {
  final String activeRoute;
  const FloatingNavbar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final items = [
      _NavItem("Home", Icons.home, AppRoutes.HOME),
      _NavItem("Kontak", Icons.contact_phone, AppRoutes.PRIORITY),
      _NavItem("Grup", Icons.group, AppRoutes.CREATE_GROUP),
      _NavItem("Profil", Icons.person, AppRoutes.PROFILE),
    ];

    return Positioned(
      bottom: 20,
      left: width * 0.05,
      right: width * 0.05,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) {
            final bool isActive = activeRoute == item.route;
            return GestureDetector(
              onTap: () {
                if (!isActive) Get.offAllNamed(item.route);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isActive ? const Color(0xFF3A4485) : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isActive ? const Color(0xFF3A4485) : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  _NavItem(this.label, this.icon, this.route);
}
