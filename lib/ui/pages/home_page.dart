import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../controllers/receipt_controller.dart';
import '../widgets/receipt_preview_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.controller});

  final ReceiptController controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _actionScrollController = ScrollController();
  double _leftPaneRatio = 0.56;
  double _settingsDrawerWidth = 460;
  ReceiptController get c => widget.controller;

  @override
  void dispose() {
    _actionScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = c.current;
    final currency = NumberFormat('#,##0', 'id_ID');

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nota Alya Florist', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)),
            Text('Cepat dicatat, rapi dicetak.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mode Gelap/Terang',
            onPressed: c.toggleDarkMode,
            icon: Icon(c.settings.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
          Tooltip(
            message: 'Profil Print: ${c.settings.printConnection} • ${c.settings.paperPreset}',
            child: IconButton(
              tooltip: 'Koneksi & Kertas Print',
              onPressed: () => _openPrintConnectionDialog(context),
              icon: const Icon(Icons.print_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Buka Pengaturan',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: _settingsDrawerWidth,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _settingsDrawerWidth = (_settingsDrawerWidth - details.delta.dx).clamp(360, 860);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.drag_indicator),
                    ),
                  ),
                  const Text('Pengaturan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Text('Geser ikon drag untuk melebarkan panel pengaturan ke kiri.'),
              const SizedBox(height: 8),
              const Text('Tema warna aplikasi', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...[...const [0xFF3F51B5, 0xFF0F9D58, 0xFFDB4437, 0xFFF4B400, 0xFF673AB7], ...c.settings.customThemeColors]
                      .map(
                        (color) => InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => c.setThemeSeed(color),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c.settings.themeSeed == color
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: c.settings.themeSeed == color
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () async {
                      final picked = await _pickColor(context);
                      if (picked != null) {
                        c.addCustomThemeColor(picked);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: const Icon(Icons.add, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tekan + untuk tambah warna custom, lalu otomatis tersimpan.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 28),
              _field('Counter nomor', '${c.settings.receiptCounter}', 'Angka awal penomoran nota. Kosongkan jadi 0.',
                  (v) => c.settings.receiptCounter = int.tryParse(v) ?? 0),
              _field('Prefix nomor', c.settings.receiptPrefix, 'Contoh: AF', (v) => c.settings.receiptPrefix = v),
              _field('Format nomor', c.settings.receiptFormat,
                  'Template: {counter}/{prefix}/{month}/{year}', (v) => c.settings.receiptFormat = v),
              _field('Skala print (%)', '${c.settings.printScale}', '70 = lebih kecil, 100 = normal',
                  (v) => c.settings.printScale = int.tryParse(v) ?? 70),
              const Divider(height: 28),
              _field('Nama Header Kwitansi', c.settings.companyName, 'Nama utama di atas kwitansi',
                  (v) => c.settings.companyName = v),
              _field('Sub Nama (Opsional)', c.settings.subName, 'Contoh: ( UD. ALYAA )',
                  (v) => c.settings.subName = v),
              _field('Slogan', c.settings.slogan, 'Contoh: Pusat Karangan Bunga, Dekorasi, Mobil Hias',
                  (v) => c.settings.slogan = v),
              _field('Alamat (tiap baris)', c.settings.addressLines.join('\n'), 'Baris alamat/info kontak di header kwitansi',
                  (v) => c.settings.addressLines = v.split('\n'), maxLines: 4),
              const Divider(height: 28),
              _field('Default penerima', c.settings.defaultRecipientName,
                  'Nama penerima default saat buat nota baru', (v) => c.settings.defaultRecipientName = v),
              _field('Default penerima baris 2', c.settings.defaultRecipientLine2,
                  'Opsional untuk institusi/divisi', (v) => c.settings.defaultRecipientLine2 = v),
              _field('Default nama barang', c.settings.defaultItemName,
                  'Contoh: Rangkaian Bunga Papan', (v) => c.settings.defaultItemName = v),
              _field('Default deskripsi', c.settings.defaultItemDescription,
                  'Isi alamat/ucapan standar', (v) => c.settings.defaultItemDescription = v, maxLines: 3),
              _field('Default harga', '${c.settings.defaultItemPrice}', 'Harga dalam Rupiah',
                  (v) => c.settings.defaultItemPrice = int.tryParse(v) ?? 0),
              _field('Default penandatangan', c.settings.defaultSigner,
                  'Nama yang muncul di tanda tangan', (v) => c.settings.defaultSigner = v),
              _field('Default pengirim (tiap baris)', c.settings.defaultSenderDetails.join('\n'),
                  'Satu baris = satu informasi pengirim', (v) => c.settings.defaultSenderDetails = v.split('\n'), maxLines: 4),
              const SizedBox(height: 8),
              _sliderField(
                'Ukuran Logo Utama',
                c.settings.logoMainScale.toDouble(),
                'Atur ukuran logo utama (1-100)',
                (v) => c.setLogoMainScale(v.round()),
              ),
              _sliderField(
                'Ukuran Logo TTD',
                c.settings.logoSignatureScale.toDouble(),
                'Atur ukuran logo tanda tangan (1-100)',
                (v) => c.setLogoSignatureScale(v.round()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(type: FileType.image);
                        if (result?.files.single.path case final p?) c.setLogoMainPath(p);
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Utama'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(type: FileType.image);
                        if (result?.files.single.path case final p?) c.setLogoSignaturePath(p);
                      },
                      icon: const Icon(Icons.brush_outlined),
                      label: const Text('TTD'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await c.resetToEmptyDefaults();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Berhasil reset ke default kosong')),
                        );
                      },
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await c.saveSettings();
                        navigator.pop();
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth < 1280 ? 1280.0 : constraints.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth,
              child: Row(
                children: [
                  SizedBox(
                    width: contentWidth * _leftPaneRatio,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Text('Form Nota', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _field('Nomor Nota', data.no, 'Nomor nota bisa edit manual', (v) => c.updateCurrent((d) => d.no = v))),
                                      const SizedBox(width: 12),
                                      Expanded(child: _field('Tanggal', data.date, 'Tanggal otomatis, bisa edit jika perlu', (v) => c.updateCurrent((d) => d.date = v))),
                                    ],
                                  ),
                                  _field('Penerima', data.recipientName, 'Contoh: Nama orang/perusahaan', (v) => c.updateCurrent((d) => d.recipientName = v)),
                                  _field('Penerima baris 2', data.recipientLine2, 'Opsional', (v) => c.updateCurrent((d) => d.recipientLine2 = v)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('Daftar Barang', style: TextStyle(fontWeight: FontWeight.w700)),
                                      const Spacer(),
                                      FilledButton.tonalIcon(onPressed: c.addItem, icon: const Icon(Icons.add), label: const Text('Tambah Item')),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(data.items.length, (i) {
                                    final item = data.items[i];
                                    return Card(
                                      key: ValueKey('item-card-${item.id}'),
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                child: _field(
                                                  'Qty',
                                                  '${item.quantity}',
                                                  'Jumlah item',
                                                  (v) => c.updateCurrent((d) => d.items[i].quantity = int.tryParse(v) ?? 1),
                                                  fieldKey: ValueKey('qty-${item.id}'),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 3,
                                                child: _field(
                                                  'Nama Barang',
                                                  item.name,
                                                  'Nama item utama',
                                                  (v) => c.updateCurrent((d) => d.items[i].name = v),
                                                  fieldKey: ValueKey('name-${item.id}'),
                                                ),
                                              ),
                                              IconButton(onPressed: () => c.removeItem(i), icon: const Icon(Icons.delete_outline)),
                                            ]),
                                            _field(
                                              'Deskripsi / Alamat / Ucapan',
                                              item.description,
                                              'Isi detail alamat + ucapan',
                                              (v) => c.updateCurrent((d) => d.items[i].description = v),
                                              maxLines: 3,
                                              fieldKey: ValueKey('desc-${item.id}'),
                                            ),
                                            _field(
                                              'Harga',
                                              '${item.price}',
                                              'Harga satuan (rupiah)',
                                              (v) => c.updateCurrent((d) => d.items[i].price = int.tryParse(v) ?? 0),
                                              fieldKey: ValueKey('price-${item.id}'),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Total: Rp ${currency.format(item.total)}',
                                                style: const TextStyle(fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 12),
                                  _field(
                                    'Pengirim (tiap baris)',
                                    data.senderDetails.join('\n'),
                                    'Satu baris untuk satu identitas pengirim',
                                    (v) => c.updateCurrent((d) => d.senderDetails = v.split('\n')),
                                    maxLines: 4,
                                  ),
                                  _field(
                                    'Penandatangan',
                                    data.signer,
                                    'Nama yang tampil di bawah tanda tangan',
                                    (v) => c.updateCurrent((d) => d.signer = v),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _leftPaneRatio = (_leftPaneRatio + (details.delta.dx / contentWidth)).clamp(0.35, 0.75);
                        });
                      },
                      child: Container(
                        width: 12,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: (contentWidth * (1 - _leftPaneRatio)) - 12,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profil print aktif: ${c.settings.printConnection} • ${c.settings.paperPreset}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    controller: _actionScrollController,
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilledButton.icon(
                                          onPressed: c.addToBatch,
                                          icon: const Icon(Icons.layers),
                                          label: Text(c.editingBatchIndex >= 0 ? 'Update Batch' : 'Tambah Batch'),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton.icon(
                                          onPressed: c.printCurrent,
                                          icon: const Icon(Icons.print),
                                          label: const Text('Nota Aktif'),
                                        ),
                                        const SizedBox(width: 10),
                                        OutlinedButton.icon(
                                          onPressed: c.batchQueue.isEmpty ? null : c.printBatch,
                                          icon: const Icon(Icons.print_outlined),
                                          label: const Text('Semua Batch'),
                                        ),
                                        if (c.batchQueue.isNotEmpty) ...[
                                          const SizedBox(width: 10),
                                          TextButton(
                                            onPressed: c.clearBatch,
                                            child: Text('Clear Batch (${c.batchQueue.length})'),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ReceiptPreviewCard(data: c.current),
                                  const SizedBox(height: 12),
                                  Card(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: c.batchQueue.length,
                                      itemBuilder: (context, index) {
                                        final r = c.batchQueue[index];
                                        return ListTile(
                                          title: Text('#${index + 1} ${r.no}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                          subtitle: Text('${r.recipientName.isEmpty ? '(Tanpa penerima)' : r.recipientName} • Rp ${currency.format(r.grandTotal)}'),
                                          onTap: () => c.editBatch(index),
                                          trailing: IconButton(onPressed: () => c.deleteBatch(index), icon: const Icon(Icons.delete_outline)),
                                        );
                                      },
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openPrintConnectionDialog(BuildContext context) async {
    String connection = c.settings.printConnection;
    String paper = c.settings.paperPreset;
    final widthController = TextEditingController(text: c.settings.customPaperWidthMm.toStringAsFixed(0));
    final heightController = TextEditingController(text: c.settings.customPaperHeightMm.toStringAsFixed(0));

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Koneksi Printer & Kertas'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: connection,
                  decoration: const InputDecoration(labelText: 'Metode Koneksi', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'Sistem (USB/IPP/Bluetooth)', child: Text('Sistem (USB/IPP/Bluetooth)')),
                    DropdownMenuItem(value: 'USB', child: Text('USB')),
                    DropdownMenuItem(value: 'IPP/Network', child: Text('IPP/Network')),
                    DropdownMenuItem(value: 'Bluetooth', child: Text('Bluetooth')),
                  ],
                  onChanged: (v) => setState(() => connection = v ?? 'Sistem (USB/IPP/Bluetooth)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: paper,
                  decoration: const InputDecoration(labelText: 'Ukuran Kertas', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'F4', child: Text('F4 (210x330)')),
                    DropdownMenuItem(value: 'A4', child: Text('A4 (210x297)')),
                    DropdownMenuItem(value: 'Letter', child: Text('Letter (216x279)')),
                    DropdownMenuItem(value: 'Thermal 80mm', child: Text('Thermal 80mm')),
                    DropdownMenuItem(value: 'Thermal 58mm', child: Text('Thermal 58mm')),
                    DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                  ],
                  onChanged: (v) => setState(() => paper = v ?? 'F4'),
                ),
                if (paper == 'Custom') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Lebar (mm)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Tinggi (mm)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                const Text(
                  'Catatan: pilihan koneksi adalah profil preferensi. Eksekusi print tetap melalui dialog print sistem (Windows/Linux) dan printer yang terpasang di OS.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                c.settings.printConnection = connection;
                c.settings.paperPreset = paper;
                c.settings.customPaperWidthMm = double.tryParse(widthController.text) ?? c.settings.customPaperWidthMm;
                c.settings.customPaperHeightMm = double.tryParse(heightController.text) ?? c.settings.customPaperHeightMm;
                await c.savePrintPreferences();
                if (context.mounted) {
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Profil print disimpan: $connection • $paper')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _pickColor(BuildContext context) async {
    double r = 63;
    double g = 81;
    double b = 181;

    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final preview = Color.fromARGB(255, r.toInt(), g.toInt(), b.toInt());
          return AlertDialog(
            title: const Text('Tambah Warna Kustom'),
            content: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(color: preview, borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(height: 12),
                  _slider('R', r, (v) => setState(() => r = v)),
                  _slider('G', g, (v) => setState(() => g = v)),
                  _slider('B', b, (v) => setState(() => b = v)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, preview.toARGB32()),
                icon: const Icon(Icons.check),
                label: const Text('Pakai'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 24, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
        Expanded(child: Slider(value: value, max: 255, min: 0, onChanged: onChanged)),
        SizedBox(width: 40, child: Text(value.toInt().toString())),
      ],
    );
  }

  Widget _sliderField(String label, double value, String note, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(note, style: Theme.of(context).textTheme.bodySmall),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.clamp(1, 100),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: value.round().toString(),
                  onChanged: onChanged,
                ),
              ),
              SizedBox(width: 42, child: Text('${value.round()}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String value,
    String note,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
    Key? fieldKey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        key: fieldKey,
        initialValue: value,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          helperText: note,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
