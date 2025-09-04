import 'dart:async';
import 'dart:developer';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();

  factory PrinterService() => _instance;

  PrinterService._internal();

  final List<BluetoothDevice> _devices = [];
  var logger = (String msg) => log(name: "PrinterService", msg);

  /// The saved device (only one at a time)
  BluetoothDevice? _savedPrinter;

  /// Returns the currently saved printer (if any)
  BluetoothDevice? get savedPrinter => _savedPrinter;
  Stream<List<BluetoothDevice>> scanDevices({
    Duration timeout = const Duration(seconds: 5),
  }) async* {
    await ensureBluetoothOn();
    await FlutterBluePlus.stopScan();

    _devices.clear();
    await FlutterBluePlus.startScan(timeout: timeout);

    yield* FlutterBluePlus.scanResults.map((results) {
      for (var r in results) {
        if (!_devices.any((d) => d.remoteId == r.device.remoteId)) {
          final dName = r.device.advName;
          if (dName.isEmpty) continue;
          _devices.add(r.device);
          logger('Device: ${r.device.advName} found');
        }
      }
      return List<BluetoothDevice>.from(_devices);
    });
  }

  Future<void> ensureBluetoothOn() async {
    // Check support
    bool supported = await FlutterBluePlus.isSupported;
    if (!supported) {
      throw Exception("Bluetooth not supported on this device");
    }

    // Get current state
    var state = await FlutterBluePlus.adapterState.first;

    // If off, request user to turn it on
    if (state != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
      // ^ On Android → shows system dialog asking user to enable
      // ^ On iOS     → this does nothing (Apple does not allow apps to turn on Bluetooth)
    }
  }

  /// Connect to a device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      final name = device.advName;
      final macaddress = device.remoteId.str;
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.remoteId.str,
      );
      _savedPrinter = device;
      if (result) {
        logger('Connected to printer: $name ($macaddress)');
      } else {
        logger('Failed to connect: $macaddress');
      }
      return result;
    } catch (e) {
      logger('Error connecting to printer: $e');
      return false;
    }
  }

  Future<bool> get isConnected async {
    bool permission = await PrintBluetoothThermal.isPermissionBluetoothGranted;
    logger('Have permission? $permission');
    return await PrintBluetoothThermal.connectionStatus;
  }

  /// Disconnect from a device
  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      if (result) {
        logger('Disconnected printer');
      }
      return result;
    } catch (e) {
      logger('Error disconnecting: $e');
      return false;
    }
  }

  /// Stop scanning (turn off discovery)
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<bool> testTicket() async {
    try {
      List<int> bytes = [];
      // Using default profile
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      //bytes += generator.setGlobalFont(PosFontType.fontA);
      bytes += generator.reset();

      // final ByteData data = await rootBundle.load('assets/mylogo.jpg');
      // final Uint8List bytesImg = data.buffer.asUint8List();
      // final image = Imag.decodeImage(bytesImg);
      // // Using `ESC *`
      // bytes += generator.image(image!);

      bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ',
        styles: PosStyles(),
      );
      bytes += generator.text(
        'Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: 'CP1252'),
      );
      bytes += generator.text(
        'Special 2: blåbærgrød',
        styles: PosStyles(codeTable: 'CP1252'),
      );
      bytes += generator.hr();

      bytes += generator.text('Bold text', styles: PosStyles(bold: true));
      bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
      bytes += generator.text(
        'Underlined text',
        styles: PosStyles(underline: true),
        linesAfter: 1,
      );
      bytes += generator.text(
        'Align left',
        styles: PosStyles(align: PosAlign.left),
      );
      bytes += generator.text(
        'Align center',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        'Align right',
        styles: PosStyles(align: PosAlign.right),
        linesAfter: 1,
      );

      bytes += generator.row([
        PosColumn(
          text: 'col3',
          width: 3,
          styles: PosStyles(align: PosAlign.center, underline: true),
        ),
        PosColumn(
          text: 'col6',
          width: 6,
          styles: PosStyles(align: PosAlign.center, underline: true),
        ),
        PosColumn(
          text: 'col3',
          width: 3,
          styles: PosStyles(align: PosAlign.center, underline: true),
        ),
      ]);

      //barcode
      final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
      bytes += generator.barcode(Barcode.upcA(barData));

      //QR code
      bytes += generator.qrcode('example.com');

      bytes += generator.text(
        'Text size 50%',
        styles: PosStyles(fontType: PosFontType.fontB),
      );
      bytes += generator.text(
        'Text size 100%',
        styles: PosStyles(fontType: PosFontType.fontA),
      );
      bytes += generator.text(
        'Text size 200%',
        styles: PosStyles(height: PosTextSize.size2, width: PosTextSize.size2),
      );

      bytes += generator.feed(2);
      //bytes += generator.cut();
      await PrintBluetoothThermal.writeBytes(bytes);
      logger('Print job sent');
      return true;
    } catch (e) {
      logger('Error printing: $e');
      return false;
    }
  }
}
