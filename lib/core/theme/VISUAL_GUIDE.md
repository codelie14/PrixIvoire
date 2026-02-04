# Visual Guide - Theme System

## Theme Showcase

### Light Theme

**Primary Colors:**
- Primary: `#FF6B35` (Orange) - Vibrant, energetic
- On Primary: `#FFFFFF` (White) - High contrast text
- Primary Container: `#FFDAD1` - Soft orange tint
- On Primary Container: `#3D0900` - Dark brown text

**Surface Colors:**
- Surface: `#FFFBFF` - Near white, warm tone
- On Surface: `#201A19` - Dark brown text
- Surface Container: `#E7E0DE` - Light gray

**Accent Colors:**
- Secondary: `#775651` - Warm brown
- Tertiary: `#6B5E2F` - Olive brown
- Error: `#BA1A1A` - Clear red

**Visual Characteristics:**
- Clean, bright appearance
- Warm color palette inspired by Ivorian markets
- High readability in daylight
- Professional yet friendly

### Dark Theme

**Primary Colors:**
- Primary: `#FFB59D` (Light Orange) - Softer for dark mode
- On Primary: `#5F1600` - Dark red-brown
- Primary Container: `#852200` - Deep orange
- On Primary Container: `#FFDAD1` - Light peach

**Surface Colors:**
- Surface: `#181211` - Very dark brown
- On Surface: `#EDE0DD` - Light beige
- Surface Container: `#3A3331` - Medium dark brown

**Accent Colors:**
- Secondary: `#E7BDB6` - Light brown
- Tertiary: `#D8C68D` - Light olive
- Error: `#FFB4AB` - Soft red

**Visual Characteristics:**
- Comfortable for low-light viewing
- Reduced eye strain
- Maintains brand identity
- Elegant and modern

## Component Styling

### AppBar
```
┌─────────────────────────────────┐
│  ← PrixIvoire          ⚙️  🔄   │
└─────────────────────────────────┘
```
- No elevation (flat design)
- Centered title
- Icon buttons for actions
- Uses surface color as background

### Cards
```
┌─────────────────────────────────┐
│  Product Name                   │
│  Store: SuperMarché             │
│  Price: 1,500 FCFA              │
│  Date: 04/02/2026               │
└─────────────────────────────────┘
```
- 12px border radius
- 2px elevation
- Subtle shadow
- Rounded corners

### Buttons

**Elevated Button:**
```
┌─────────────────────┐
│  Saisir un prix     │
└─────────────────────┘
```
- 8px border radius
- 2px elevation
- Horizontal padding: 24px
- Vertical padding: 12px

**Filled Button:**
```
┌─────────────────────┐
│  Enregistrer        │
└─────────────────────┘
```
- 8px border radius
- Solid fill color
- No elevation
- Same padding as elevated

### Input Fields
```
┌─────────────────────────────────┐
│  Nom du produit                 │
│  Banane plantain                │
└─────────────────────────────────┘
```
- Filled style (no outline)
- 8px border radius
- 2px focus border (primary color)
- 16px horizontal padding
- 16px vertical padding

### SnackBar
```
┌─────────────────────────────────┐
│  ✓ Prix enregistré avec succès  │
└─────────────────────────────────┘
```
- Floating behavior
- 8px border radius
- Appears at bottom
- Auto-dismiss after 4 seconds

### Floating Action Button
```
    ┌─────┐
    │  +  │
    └─────┘
```
- 16px border radius
- 4px elevation
- Primary color
- Positioned bottom-right

## Settings Screen Layout

```
┌─────────────────────────────────┐
│  ← Paramètres                   │
├─────────────────────────────────┤
│                                 │
│  Apparence                      │
│                                 │
│  🌓  Thème                      │
│     Système                  >  │
│                                 │
├─────────────────────────────────┤
│  (More settings sections...)    │
│                                 │
└─────────────────────────────────┘
```

## Theme Selection Dialog

```
┌─────────────────────────────────┐
│  Choisir le thème               │
├─────────────────────────────────┤
│                                 │
│  ☀️  Clair                      │
│                                 │
│  🌙  Sombre                     │
│                                 │
│  🌓  Système              ✓     │
│                                 │
├─────────────────────────────────┤
│                      ANNULER    │
└─────────────────────────────────┘
```

## Color Usage Examples

### Light Theme in Action

**Home Screen:**
- Background: Surface (#FFFBFF)
- AppBar: Primary (#FF6B35)
- Cards: Surface with elevation
- Text: On Surface (#201A19)
- Buttons: Primary (#FF6B35)

**Add Price Screen:**
- Background: Surface (#FFFBFF)
- Input fields: Surface Container (#E7E0DE)
- Labels: On Surface (#201A19)
- Save button: Primary (#FF6B35)
- Error text: Error (#BA1A1A)

### Dark Theme in Action

**Home Screen:**
- Background: Surface (#181211)
- AppBar: Surface (#181211)
- Cards: Surface Container (#3A3331)
- Text: On Surface (#EDE0DD)
- Buttons: Primary (#FFB59D)

**Add Price Screen:**
- Background: Surface (#181211)
- Input fields: Surface Container (#3A3331)
- Labels: On Surface (#EDE0DD)
- Save button: Primary (#FFB59D)
- Error text: Error (#FFB4AB)

## Transition Animation

When switching themes:
1. User selects new theme in dialog
2. Dialog closes immediately
3. Theme changes propagate in < 100ms
4. All visible widgets update smoothly
5. No flicker or jarring transitions
6. Smooth color interpolation

## Responsive Behavior

### System Theme Mode
- Automatically follows OS dark mode setting
- Updates when OS theme changes
- Respects user's system preferences
- Seamless integration with platform

### Manual Theme Selection
- Overrides system preference
- Persists across app restarts
- Immediate visual feedback
- Clear indication of current selection

## Accessibility Features

### High Contrast
- All text meets WCAG AA standards
- Clear visual hierarchy
- Distinct interactive elements
- Readable in various lighting

### Screen Reader Support
- Semantic labels on all controls
- Clear navigation structure
- Descriptive button labels
- Accessible dialogs

### Touch Targets
- Minimum 48x48 dp touch targets
- Adequate spacing between elements
- Clear focus indicators
- Easy to tap buttons

## Best Practices for Using Themes

### DO:
✅ Use `Theme.of(context).colorScheme.primary` for colors
✅ Use semantic color names (primary, surface, error)
✅ Respect the theme's color scheme
✅ Test in both light and dark modes
✅ Use Material Design 3 components

### DON'T:
❌ Hardcode colors (e.g., `Colors.orange`)
❌ Assume light theme only
❌ Use colors that don't meet contrast requirements
❌ Override theme colors without good reason
❌ Forget to test dark mode

## Code Examples

### Using Theme Colors
```dart
// Good
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)

// Bad
Container(
  color: Colors.orange,
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.white),
  ),
)
```

### Accessing Current Theme
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final primaryColor = Theme.of(context).colorScheme.primary;
final textTheme = Theme.of(context).textTheme;
```

### Changing Theme
```dart
final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
await themeProvider.setThemeMode(ThemeMode.dark);
```

## Testing Themes

### Visual Testing Checklist:
- [ ] All screens render correctly in light mode
- [ ] All screens render correctly in dark mode
- [ ] Text is readable in both modes
- [ ] Buttons are clearly visible
- [ ] Input fields are distinguishable
- [ ] Error states are clear
- [ ] Loading indicators are visible
- [ ] Icons are appropriate for theme
- [ ] Shadows/elevations work well
- [ ] Transitions are smooth

### Accessibility Testing:
- [ ] Contrast ratios meet WCAG AA
- [ ] Screen reader announces correctly
- [ ] Focus indicators are visible
- [ ] Touch targets are adequate
- [ ] Color is not the only indicator

## Platform-Specific Considerations

### Android:
- Respects system dark mode (Android 10+)
- Material Design 3 components
- Ripple effects on interactions
- System navigation bar theming

### iOS:
- Respects system dark mode (iOS 13+)
- Cupertino-style adaptations where appropriate
- Smooth transitions
- System status bar theming

### Web:
- Respects browser/OS dark mode
- Responsive design
- Proper color rendering
- Accessibility features

## Future Enhancements

Potential visual improvements:
- Custom accent color picker
- Multiple theme presets (Ocean, Forest, Sunset)
- Dynamic color from wallpaper (Android 12+)
- Theme preview before applying
- Animated theme transitions
- Per-screen theme overrides
- Seasonal themes
- High contrast mode
