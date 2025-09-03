import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_printer/printer_service.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final printerService = PrinterService();
  List<BluetoothInfo> bluetoothDevices = [];
  @override
  void initState() {
    super.initState();
    printerService.getPairedDevices().then((devices) {
      setState(() {
        bluetoothDevices = devices;
      });
      log('Paired devices: $devices');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: bluetoothDevices.length,
        itemBuilder: (context, index) {
          final printer = bluetoothDevices[index];
          return ListTile(
            title: Text(printer.name),
            subtitle: Text(" ${printer.macAdress}"),
            onTap: () async {
              if (await printerService.isConnected) {
                await printerService.disconnect();
              } else {
                await printerService.connect(printer.macAdress);
              }
            },
            trailing: IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                await printerService.printTestReceipt();
              },
            ),
          );
        },
      ),
    );
  }
}
