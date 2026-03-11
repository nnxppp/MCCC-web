import 'package:example/models/labSample.dart';
import 'package:example/screens/labForm.dart';
import 'package:example/screens/labShow.dart';
import 'package:example/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:example/providers/showSample_providers.dart';

class MainShowPage extends StatefulWidget {
  final String sampName;

  const MainShowPage({super.key, required this.sampName});

  @override
  State<MainShowPage> createState() => _MainShowPageState();
}

class _MainShowPageState extends State<MainShowPage>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  LabSample? labData;

  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentImageIndex = 0;

  final Color primaryGreen = const Color(0xFF006A4E);
  final Color softGreen = const Color(0xFFF4F9F4);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<ShowsampleProviders>(context, listen: false);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await provider.loadSampleDetail(widget.sampName);
        if (mounted && provider.selectedSample?.lab != null) {
          setState(() => labData = provider.selectedSample!.lab);
        }
        _controller.forward();
      });
      _initialized = true;
    }
  }

  // ================= INFO CARD =================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: primaryGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : "-",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SECTION =================

  Widget _section(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      color: const Color(0xFFE8F3EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: children
                  .map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: w,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _twoSide(Widget left, Widget right) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 900) {
        return Column(
          children: [
            left,
            const SizedBox(height: 12),
            right,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: 14),
          Expanded(child: right),
        ],
      );
    });
  }

  // ================= IMAGE GALLERY =================

  Widget _buildImages(List<String> images) {
    final bool showArrow = images.length > 1;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemBuilder: (_, i) {
              final img = images[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: img.startsWith("http")
                      ? Image.network(img, fit: BoxFit.cover)
                      : Image.asset("assets/$img", fit: BoxFit.cover),
                ),
              );
            },
          ),
          if (showArrow && _currentImageIndex > 0)
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: _nav(
                Icons.chevron_left,
                () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
              ),
            ),
          if (showArrow && _currentImageIndex < images.length - 1)
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: _nav(
                Icons.chevron_right,
                () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _nav(IconData icon, VoidCallback onTap) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: primaryGreen.withOpacity(0.8),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  // ================= SAMPLE TAB =================

  Widget _sampleTab(ShowsampleProviders p) {
    final s = p.selectedSample!;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _twoSide(
              _section("Sample Info", [
                _infoCard(
                    icon: Icons.title,
                    title: "Title",
                    value: s.sampTitle ?? ""),
                _infoCard(
                    icon: Icons.date_range,
                    title: "Collection Date",
                    value: s.collectionDate?.toString() ?? ""),
                _infoCard(
                    icon: Icons.description,
                    title: "Description",
                    value: s.description ?? ""),
                _infoCard(
                    icon: Icons.bug_report,
                    title: "Organism",
                    value: s.organism ?? ""),
                _infoCard(
                    icon: Icons.science,
                    title: "Collection Method",
                    value: s.collectMeth ?? ""),
                _infoCard(
                    icon: Icons.device_hub,
                    title: "Sample Device",
                    value: s.sampCollectDevice ?? ""),
                _infoCard(
                    icon: Icons.category,
                    title: "Sample Size",
                    value: s.sampSize?.toString() ?? ""),
                _infoCard(
                    icon: Icons.folder_special,
                    title: "Bioproject ID",
                    value: s.bioprojectId ?? ""),
              ]),
              _section("Environment Info", [
                _infoCard(
                  icon: Icons.map,
                  title: "Lat / Long",
                  value: "${s.geoLatlon?[0] ?? "-"}, ${s.geoLatlon?[1] ?? "-"}",
                ),
                _infoCard(
                    icon: Icons.terrain,
                    title: "Altitude",
                    value: s.alt?.toString() ?? ""),
                _infoCard(
                  icon: Icons.place,
                  title: "Address",
                  value:
                      "${s.addressSubdistrict ?? "-"} ${s.addressDistrict ?? ""} ${s.addressProvince ?? ""}",
                ),
                _infoCard(
                    icon: Icons.thermostat,
                    title: "Temperature",
                    value: s.temp?.toString() ?? ""),
                _infoCard(
                    icon: Icons.opacity,
                    title: "Humidity",
                    value: s.humidity?.toString() ?? ""),
                _infoCard(
                    icon: Icons.grain,
                    title: "Precipitation",
                    value: s.precpt?.toString() ?? ""),
              ]),
            ),
            const SizedBox(height: 12),
            _twoSide(
              _section("Area History", [
                _infoCard(
                    icon: Icons.agriculture,
                    title: "Agrochemical",
                    value: s.agrochemAddition ?? ""),
                _infoCard(
                    icon: Icons.recycling,
                    title: "Crop Rotation",
                    value: s.cropRotation ?? ""),
                _infoCard(
                    icon: Icons.landscape,
                    title: "Current Land Use",
                    value: s.curLandUse ?? ""),
                _infoCard(
                    icon: Icons.park,
                    title: "Vegetation",
                    value: s.curVegetation ?? ""),
                _infoCard(
                    icon: Icons.water_damage,
                    title: "Flooding",
                    value: s.flooding ?? ""),
                _infoCard(
                    icon: Icons.local_fire_department,
                    title: "Fire",
                    value: s.fire ?? ""),
                _infoCard(
                    icon: Icons.history,
                    title: "Previous Land Use",
                    value: s.previousLandUse ?? ""),
                _infoCard(
                    icon: Icons.construction,
                    title: "Previous Method",
                    value: s.previousLandUseMeth ?? ""),
              ]),
              _section("Collected By", [
                _infoCard(
                    icon: Icons.person,
                    title: "Name",
                    value: s.collectedByName ?? ""),
              ]),
            ),
            if (s.pictures != null && s.pictures!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _section(
                  "Images",
                  [
                    _buildImages(s.pictures!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ================= LAB TAB =================

  // ================= LAB TAB =================

  Widget _labTab() {
    // กรณี 1: ยังไม่มีข้อมูล (แสดง Form)
    if (labData == null) {
      // เพิ่ม SingleChildScrollView เผื่อ Form ยาวเกินหน้าจอ
      return SingleChildScrollView(
        child: LabFormWidget(
          sampleName: widget.sampName,
          onSaved: (newLab) => setState(() => labData = newLab),
        ),
      );
    }

    // กรณี 2: มีข้อมูลแล้ว (แสดงผล)
    // ** แก้ไข: เพิ่ม SingleChildScrollView ครอบไว้เพื่อให้เลื่อนได้ **
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LabInfoDisplay(
          lab: labData!,
          onEdit: () async {
            final updatedLab = await Navigator.push<LabSample>(
              context,
              MaterialPageRoute(
                builder: (_) => LabFormWidget(
                  sampleName: widget.sampName,
                  initialLab: labData,
                ),
              ),
            );
            if (updatedLab != null) {
              setState(() => labData = updatedLab);
            }
          },
        ),
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: softGreen,
        appBar: AppBar(
          backgroundColor: primaryGreen,
          title: Text("รายละเอียด ${widget.sampName}"),
          actions: [
            // ================== ปุ่ม PRINT ==================
            // ใช้ Consumer เพื่อดึงข้อมูลปัจจุบันจาก Provider
            Consumer<ShowsampleProviders>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: const Icon(Icons.print, color: Colors.white),
                  tooltip: "Print Report",
                  onPressed: () {
                    if (provider.selectedSample != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportScreen(
                            sampleData: provider.selectedSample!,
                            // ส่งข้อมูล Lab ที่เก็บไว้ใน State ของหน้านี้ไปด้วย
                            labData: labData, 
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Data not ready")),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 8),
            // ===============================================
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                icon: Icon(Icons.folder),
                text: "Sample",
              ),
              Tab(
                icon: Icon(Icons.science),
                text: "Laboratory",
              ),
            ],
          ),
        ),
        body: Consumer<ShowsampleProviders>(
          builder: (_, p, __) {
            if (p.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (p.selectedSample == null) {
              return const Center(child: Text("ไม่พบข้อมูล"));
            }
            return TabBarView(
              children: [
                _sampleTab(p),
                _labTab(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }
}