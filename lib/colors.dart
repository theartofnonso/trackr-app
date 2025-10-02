import 'dart:ui';

// Custom colors
const vibrantGreen = Color.fromRGBO(43, 242, 12, 1);
const vibrantBlue = Color.fromRGBO(3, 140, 236, 1.0);

// Dark mode colors - Lightened dark theme
const darkBackground = Color.fromRGBO(20, 20, 20, 1); // Lightened black
const darkSurface = Color.fromRGBO(30, 30, 30, 1); // Lightened dark gray
const darkSurfaceVariant = Color.fromRGBO(40, 40, 40, 1); // Lightened dark gray
const darkSurfaceContainer =
    Color.fromRGBO(50, 50, 50, 1); // Lightened dark container
const darkOnSurface = Color.fromRGBO(255, 255, 255, 1); // White text
const darkOnSurfaceVariant =
    Color.fromRGBO(200, 200, 200, 1); // Light gray text
const darkOnSurfaceSecondary =
    Color.fromRGBO(150, 150, 150, 1); // Medium gray text
const darkBorder = Color.fromRGBO(70, 70, 70, 1); // Lightened dark border
const darkBorderLight = Color.fromRGBO(50, 50, 50, 1); // Lightened dark border
const darkDivider = Color.fromRGBO(60, 60, 60, 1); // Lightened dark divider

// Border Radius System - More prominent and consistent
const double radiusXS = 4.0; // Very small elements (badges, small buttons)
const double radiusSM = 8.0; // Small elements (text fields, small containers)
const double radiusMD = 12.0; // Medium elements (cards, buttons, input fields)
const double radiusLG = 16.0; // Large elements (modals, large cards)
const double radiusXL =
    20.0; // Extra large elements (bottom sheets, major containers)
const double radiusXXL =
    24.0; // Very large elements (full-screen modals, major UI sections)
const double radiusRound =
    50.0; // Circular elements (floating action buttons, avatars)
