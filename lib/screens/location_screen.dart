import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../services/settings_service.dart';
import '../services/saved_locations_service.dart';
import '../services/localization_service.dart';
import '../models/saved_location.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LocationScreen extends StatefulWidget {
  final VoidCallback? onBackToCompass;
  
  const LocationScreen({Key? key, this.onBackToCompass}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final GlobalKey _screenshotKey = GlobalKey();
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationService = Provider.of<LocationService>(context, listen: false);
      if (locationService.currentPosition == null) {
        locationService.getCurrentLocation();
      }
    });
  }

  String _convertToDMS(double decimal, bool isLatitude) {
    final direction = isLatitude
        ? (decimal >= 0 ? LocalizationService.translate('n') : LocalizationService.translate('s'))
        : (decimal >= 0 ? LocalizationService.translate('e') : LocalizationService.translate('w'));
    
    decimal = decimal.abs();
    final degrees = decimal.floor();
    final minutesDecimal = (decimal - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;
    
    return '$degrees°${minutes}\'${seconds.toStringAsFixed(2)}"$direction';
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$label ${LocalizationService.translate('copied_to_clipboard')}'),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _saveLocation(BuildContext context) async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final savedLocationsService = Provider.of<SavedLocationsService>(context, listen: false);
    
    if (locationService.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService.translate('no_location_to_save')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nameController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategoryKey = 'Favorite';
    IconData selectedIcon = Icons.favorite;

    final categories = [
      {'name': LocalizationService.translate('home'), 'key': 'Home', 'icon': Icons.home},
      {'name': LocalizationService.translate('work'), 'key': 'Work', 'icon': Icons.work},
      {'name': LocalizationService.translate('favorite'), 'key': 'Favorite', 'icon': Icons.favorite},
      {'name': LocalizationService.translate('restaurant'), 'key': 'Restaurant', 'icon': Icons.restaurant},
      {'name': LocalizationService.translate('shopping'), 'key': 'Shopping', 'icon': Icons.shopping_bag},
      {'name': LocalizationService.translate('gas_station'), 'key': 'Gas Station', 'icon': Icons.local_gas_station},
      {'name': LocalizationService.translate('parking'), 'key': 'Parking', 'icon': Icons.local_parking},
      {'name': LocalizationService.translate('hotel'), 'key': 'Hotel', 'icon': Icons.hotel},
      {'name': LocalizationService.translate('hospital'), 'key': 'Hospital', 'icon': Icons.local_hospital},
      {'name': LocalizationService.translate('school'), 'key': 'School', 'icon': Icons.school},
      {'name': LocalizationService.translate('other'), 'key': 'Other', 'icon': Icons.place},
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(LocalizationService.translate('save_location')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: LocalizationService.translate('location_name'),
                    hintText: LocalizationService.translate('location_name_hint'),
                    prefixIcon: const Icon(Icons.label),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizationService.translate('category'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selectedCategoryKey == cat['key'];
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              cat['name'] as String,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: _getCategoryColorByKey(cat['key'] as String),
                      onSelected: (selected) {
                        setState(() {
                          selectedCategoryKey = cat['key'] as String;
                          selectedIcon = cat['icon'] as IconData;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: LocalizationService.translate('notes_optional'),
                    hintText: LocalizationService.translate('notes_hint'),
                    prefixIcon: const Icon(Icons.notes),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              LocalizationService.translate('location_details_label'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${locationService.currentPosition!.latitude.toStringAsFixed(6)}, ${locationService.currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (locationService.currentAddress != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          locationService.currentAddress!,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(LocalizationService.translate('cancel')),
            ),
            ElevatedButton.icon(
              onPressed: nameController.text.isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              icon: const Icon(Icons.save),
              label: Text(LocalizationService.translate('save')),
            ),
          ],
        ),
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final newLocation = SavedLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        latitude: locationService.currentPosition!.latitude,
        longitude: locationService.currentPosition!.longitude,
        timestamp: DateTime.now(),
        category: selectedCategoryKey,
        notes: notesController.text.isNotEmpty ? notesController.text : null,
        address: locationService.currentAddress,
        altitude: locationService.currentPosition!.altitude,
        accuracy: locationService.currentPosition!.accuracy,
      );

      await savedLocationsService.addLocation(newLocation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${nameController.text} ${LocalizationService.translate('saved_successfully')}'),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Color _getCategoryColorByKey(String categoryKey) {
    if (categoryKey == 'Home') {
      return Colors.blue;
    } else if (categoryKey == 'Work') {
      return Colors.orange;
    } else if (categoryKey == 'Favorite') {
      return Colors.red;
    } else if (categoryKey == 'Restaurant') {
      return Colors.deepOrange;
    } else if (categoryKey == 'Shopping') {
      return Colors.purple;
    } else if (categoryKey == 'Gas Station') {
      return Colors.green;
    } else if (categoryKey == 'Parking') {
      return Colors.indigo;
    } else if (categoryKey == 'Hotel') {
      return Colors.cyan;
    } else if (categoryKey == 'Hospital') {
      return Colors.pink;
    } else if (categoryKey == 'School') {
      return Colors.amber;
    } else {
      return Colors.teal;
    }
  }

  /// Captures the widget as PNG bytes from the RepaintBoundary.
  Future<Uint8List> _captureScreenshot() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final RenderRepaintBoundary boundary =
        _screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Saves PNG bytes directly to the public Downloads folder using
  /// the MediaStore content URI on Android, or the Documents directory on iOS.
  Future<String> _saveToDownloads(Uint8List pngBytes) async {
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = 'location_$timestamp.png';

    if (Platform.isAndroid) {
      // Use MediaStore via a MethodChannel so the file is visible in Gallery/Files.
      // Falls back to direct file write if the channel is unavailable.
      try {
        const channel = MethodChannel('com.compasssafepro/media_store');
        final String? savedPath = await channel.invokeMethod<String>(
          'saveImageToDownloads',
          {'fileName': fileName, 'bytes': pngBytes},
        );
        if (savedPath != null && savedPath.isNotEmpty) return savedPath;
      } on MissingPluginException {
        // Channel not implemented — fall through to direct file write.
      } on PlatformException {
        // Channel error — fall through to direct file write.
      }

      // Direct write fallback: /storage/emulated/0/Download
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        return file.path;
      }

      // Last resort: external storage root
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final file = File('${extDir.path}/$fileName');
        await file.writeAsBytes(pngBytes);
        return file.path;
      }
    }

    // iOS / other: save to application documents directory
    final docsDir = await getApplicationDocumentsDirectory();
    final file = File('${docsDir.path}/$fileName');
    await file.writeAsBytes(pngBytes);
    return file.path;
  }

  Future<void> _captureAndDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final pngBytes = await _captureScreenshot();
      final filePath = await _saveToDownloads(pngBytes);
      final fileName = filePath.split('/').last;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.download_done, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${LocalizationService.translate('saved_to')} $fileName',
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${LocalizationService.translate('error_saving')} $e'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _captureAndShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final pngBytes = await _captureScreenshot();

      // Write to a TEMP file — never touches Downloads
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/location_$timestamp.png');
      await tempFile.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: LocalizationService.translate('share_text'),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${LocalizationService.translate('error_sharing')} $e'),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  String _getCardinalDirection(double heading) {
    final directions = [
      LocalizationService.translate('n'),
      LocalizationService.translate('ne'),
      LocalizationService.translate('e'),
      LocalizationService.translate('se'),
      LocalizationService.translate('s'),
      LocalizationService.translate('sw'),
      LocalizationService.translate('w'),
      LocalizationService.translate('nw')
    ];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  String _getAccuracyQuality(double accuracy) {
    if (accuracy < 5) {
      return LocalizationService.translate('excellent');
    } else if (accuracy < 10) {
      return LocalizationService.translate('good');
    } else if (accuracy < 20) {
      return LocalizationService.translate('fair');
    } else if (accuracy < 50) {
      return LocalizationService.translate('poor');
    } else {
      return LocalizationService.translate('very_poor');
    }
  }

  Color _getAccuracyQualityColor(double accuracy) {
    if (accuracy < 5) {
      return Colors.green;
    } else if (accuracy < 10) {
      return Colors.lightGreen;
    } else if (accuracy < 20) {
      return Colors.orange;
    } else if (accuracy < 50) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final settings = Provider.of<SettingsService>(context);
    final position = locationService.currentPosition;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(settings),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            position == null
                ? _buildLoadingState(settings)
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 60,
                      bottom: 30,
                      left: 12,
                      right: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accuracy warning banner
                        if (position.accuracy > 15)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange[300],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    LocalizationService.translate('poor_gps_signal'),
                                    style: TextStyle(
                                      color: settings.getTextColor(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        RepaintBoundary(
                          key: _screenshotKey,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _getGradientColors(settings),
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: settings.getIconColor(opacity: 0.2),
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 36,
                                          color: settings.getIconColor(),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          LocalizationService.translate('location_details'),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: settings.getTextColor(),
                                            letterSpacing: 0.5,
                                            height: 1.2,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateTime.now().toString().split('.')[0],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: settings.getTextColor(opacity: 0.7),
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Address Card
                                if (locationService.currentAddress != null)
                                  _buildAddressCardScreenshot(locationService.currentAddress!, settings),
                                
                                const SizedBox(height: 20),
                                
                                // Primary Stats Grid
                                _buildPrimaryStatsGrid(position, settings),
                                
                                const SizedBox(height: 20),
                                
                                // Coordinates Section
                                _buildSectionTitle(LocalizationService.translate('coordinates'), Icons.my_location, settings),
                                const SizedBox(height: 10),
                                
                                _buildCoordinateCardScreenshot(
                                  LocalizationService.translate('decimal_degrees'),
                                  '${LocalizationService.translate('lat_label')} ${position.latitude.toStringAsFixed(6)}\n${LocalizationService.translate('lon_label')} ${position.longitude.toStringAsFixed(6)}',
                                  Icons.pin_drop,
                                  settings,
                                ),
                                
                                const SizedBox(height: 10),
                                
                                _buildCoordinateCardScreenshot(
                                  LocalizationService.translate('degrees_minutes_seconds'),
                                  '${_convertToDMS(position.latitude, true)}\n${_convertToDMS(position.longitude, false)}',
                                  Icons.explore,
                                  settings,
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Precision Stats
                                _buildSectionTitle(LocalizationService.translate('accuracy_precision'), Icons.gps_fixed, settings),
                                const SizedBox(height: 10),
                                _buildPrecisionStats(position, settings),
                                
                                const SizedBox(height: 20),
                                
                                // Heading / Direction
                                _buildSectionTitle(LocalizationService.translate('movement_data'), Icons.trending_up, settings),
                                const SizedBox(height: 10),
                                _buildDirectionStats(position, settings),
                                
                                const SizedBox(height: 20),
                                
                                // Additional Details
                                _buildSectionTitle(LocalizationService.translate('additional_information'), Icons.info_outline, settings),
                                const SizedBox(height: 10),
                                _buildAdditionalInfo(position, settings),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Action Buttons (outside screenshot)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _saveLocation(context),
                                      icon: const Icon(Icons.bookmark_add, size: 20),
                                      label: Flexible(
                                        child: Text(
                                          LocalizationService.translate('save'),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _getAccentColor(settings),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 10),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isDownloading ? null : _captureAndDownload,
                                      icon: _isDownloading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.download, size: 20),
                                      label: Flexible(
                                        child: Text(
                                          LocalizationService.translate('download'),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: settings.getIconColor(opacity: 0.25),
                                        foregroundColor: settings.getTextColor(),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isSharing ? null : _captureAndShare,
                                      icon: _isSharing
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.share, size: 20),
                                      label: Flexible(
                                        child: Text(
                                          LocalizationService.translate('share'),
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _getSecondaryAccentColor(settings),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            
            // Back button
            if (widget.onBackToCompass != null)
              Positioned(
                top: 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onBackToCompass,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: settings.getIconColor(opacity: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: settings.getIconColor(),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Refresh button
            if (position != null)
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      locationService.refreshLocation();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: settings.getIconColor(opacity: 0.3),
                          width: 1,
                        ),
                      ),
                      child: locationService.isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(settings.getIconColor()),
                              ),
                            )
                          : Icon(
                              Icons.refresh,
                              color: settings.getIconColor(),
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(SettingsService settings) {
    switch (settings.iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF003344),
          const Color(0xFF004455),
          const Color(0xFF005566),
        ];
      case 'night':
        return [
          const Color(0xFF330011),
          const Color(0xFF440022),
          const Color(0xFF550033),
        ];
      default:
        return [
          const Color(0xFF667eea),
          const Color(0xFF764ba2),
          const Color(0xFF6B8DD6),
        ];
    }
  }

  Color _getAccentColor(SettingsService settings) {
    switch (settings.iconThemeMode) {
      case 'glow':
        return const Color(0xFF00CC88);
      case 'night':
        return const Color(0xFFDD3333);
      default:
        return Colors.green;
    }
  }

  Color _getSecondaryAccentColor(SettingsService settings) {
    switch (settings.iconThemeMode) {
      case 'glow':
        return const Color(0xFF0088CC);
      case 'night':
        return const Color(0xFFCC3344);
      default:
        return const Color(0xFF5E72E4);
    }
  }

  Widget _buildLoadingState(SettingsService settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: settings.getIconColor(opacity: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              color: settings.getIconColor(),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              LocalizationService.translate('getting_location'),
              style: TextStyle(
                color: settings.getTextColor(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              LocalizationService.translate('ensure_location_permissions'),
              style: TextStyle(
                color: settings.getTextColor(opacity: 0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCardScreenshot(String address, SettingsService settings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.2),
            settings.getIconColor(opacity: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: settings.getIconColor(opacity: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_city,
              color: settings.getIconColor(),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocalizationService.translate('location_address'),
                  style: TextStyle(
                    color: settings.getTextColor(opacity: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(
                    color: settings.getTextColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatsGrid(position, SettingsService settings) {
    final altitudeM = position.altitude ?? 0.0;
    final accuracyM = position.accuracy;
    final heading = position.heading >= 0 && position.heading <= 360 ? position.heading : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.15),
            settings.getIconColor(opacity: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  LocalizationService.translate('altitude'),
                  altitudeM.toStringAsFixed(1),
                  LocalizationService.translate('m'),
                  Icons.terrain,
                  _getStatColor(settings, 0),
                  settings,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  LocalizationService.translate('accuracy'),
                  accuracyM.toStringAsFixed(1),
                  LocalizationService.translate('m'),
                  Icons.gps_fixed,
                  _getAccuracyQualityColor(accuracyM),
                  settings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  LocalizationService.translate('heading'),
                  '${heading.toStringAsFixed(0)}${LocalizationService.translate('degree')}',
                  _getCardinalDirection(heading),
                  Icons.navigation,
                  _getStatColor(settings, 1),
                  settings,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  LocalizationService.translate('accuracy_precision'),
                  _getAccuracyQuality(accuracyM),
                  '',
                  Icons.signal_cellular_alt,
                  _getAccuracyQualityColor(accuracyM),
                  settings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatColor(SettingsService settings, int index) {
    switch (settings.iconThemeMode) {
      case 'glow':
        return [
          const Color(0xFF00FF88),
          const Color(0xFF00DDFF),
          const Color(0xFFFFCC00),
          const Color(0xFFDD00FF),
        ][index % 4];
      case 'night':
        return [
          const Color(0xFFFF6666),
          const Color(0xFFFF4488),
          const Color(0xFFFFAA44),
          const Color(0xFFFF88DD),
        ][index % 4];
      default:
        return [Colors.green, Colors.blue, Colors.orange, Colors.purple][index % 4];
    }
  }

  Widget _buildSectionTitle(String title, IconData icon, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: settings.getIconColor(opacity: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: settings.getIconColor(), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: settings.getTextColor(),
                fontSize: 19,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateCardScreenshot(
    String format,
    String value,
    IconData icon,
    SettingsService settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.15),
            settings.getIconColor(opacity: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: settings.getIconColor(opacity: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: settings.getIconColor(),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format,
                  style: TextStyle(
                    color: settings.getTextColor(opacity: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: settings.getTextColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
    SettingsService settings,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: settings.getIconColor(opacity: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: settings.getTextColor(opacity: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: settings.getTextColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: TextStyle(
                      color: settings.getTextColor(opacity: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrecisionStats(position, SettingsService settings) {
    final accuracyConverted = position.accuracy;
    final altitudeAccuracyConverted = position.altitudeAccuracy ?? 0.0;
    final headingAccuracy = position.headingAccuracy ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.12),
            settings.getIconColor(opacity: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            LocalizationService.translate('horizontal_accuracy'),
            '${LocalizationService.translate('plus_minus')}${accuracyConverted.toStringAsFixed(1)} ${LocalizationService.translate('m')} (${_getAccuracyQuality(position.accuracy)})',
            Icons.unfold_more,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            LocalizationService.translate('altitude_accuracy'),
            '${LocalizationService.translate('plus_minus')}${altitudeAccuracyConverted.toStringAsFixed(1)} ${LocalizationService.translate('m')}',
            Icons.height,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            LocalizationService.translate('heading_accuracy'),
            '${LocalizationService.translate('plus_minus')}${headingAccuracy.toStringAsFixed(1)}${LocalizationService.translate('degree')}',
            Icons.explore,
            settings,
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionStats(position, SettingsService settings) {
    final heading = position.heading >= 0 && position.heading <= 360 ? position.heading : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.12),
            settings.getIconColor(opacity: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            LocalizationService.translate('direction'),
            '${heading.toStringAsFixed(1)}${LocalizationService.translate('degree')} ${_getCardinalDirection(heading)}',
            Icons.navigation,
            settings,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(position, SettingsService settings) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            settings.getIconColor(opacity: 0.12),
            settings.getIconColor(opacity: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: settings.getIconColor(opacity: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            LocalizationService.translate('timestamp'),
            position.timestamp?.toString().split('.')[0] ?? LocalizationService.translate('n_a'),
            Icons.access_time,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            LocalizationService.translate('provider'),
            LocalizationService.translate('gps'),
            Icons.satellite_alt,
            settings,
          ),
          _buildDivider(settings),
          _buildInfoRow(
            LocalizationService.translate('floor_level'),
            position.floor?.toString() ?? LocalizationService.translate('n_a'),
            Icons.stairs,
            settings,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: settings.getIconColor(opacity: 0.8),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: settings.getTextColor(opacity: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  color: settings.getTextColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(SettingsService settings) {
    return Divider(
      height: 1,
      thickness: 1,
      color: settings.getIconColor(opacity: 0.1),
    );
  }
}