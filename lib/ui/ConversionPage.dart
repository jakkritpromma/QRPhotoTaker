import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/ConversionBloc.dart';
import '../bloc/ConversionEvent.dart';
import '../bloc/ConversionState.dart';

class ConversionPage extends StatelessWidget {
  String TAG = "ConversionPage MyLog ";
  final TextEditingController controllerE = TextEditingController(text: "0");
  final TextEditingController controllerM = TextEditingController(text: "0");

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConversionBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Energy Mass Conversion")),
        body: BlocListener<ConversionBloc, ConversionState>(
          listener: (context, state) {
            final cursorPos1 = controllerE.selection.baseOffset;
            print("${TAG}cursorPos1: $cursorPos1");
            final cursorPos2 = controllerM.selection.baseOffset;
            print("${TAG}cursorPos2: $cursorPos2");

            controllerE.text = state.energy.toStringAsFixed(2);
            controllerM.text = state.mass.toStringAsFixed(2);

            if (cursorPos1 > -1) {
              controllerE.selection = TextSelection.fromPosition(
                TextPosition(offset: cursorPos1),
              );
            }
            if (cursorPos2 > -2) {
              controllerM.selection = TextSelection.fromPosition(
                TextPosition(offset: cursorPos2),
              );
            }
          },
          child: BlocBuilder<ConversionBloc, ConversionState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            TextField(
                              controller: controllerE,
                              decoration: const InputDecoration(
                                label: Center(
                                  child: Text(
                                    "E",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                print("${TAG}value: $value");
                                context.read<ConversionBloc>().add(M1Changed(double.tryParse(value) ?? 0));
                              },
                            ),
                            const Text(
                              "Joules",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        )),
                        const SizedBox(width: 10),
                        const Text('\n='),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                          children: [
                            TextField(
                              controller: controllerM,
                              decoration: const InputDecoration(
                                label: Center(
                                  child: Text(
                                    "m",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<ConversionBloc>().add(M2Changed(double.tryParse(value) ?? 0));
                              },
                            ),
                            const Text(
                              "kilograms",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        )),
                        const SizedBox(width: 10),
                        const Text('\nx'),
                        const SizedBox(width: 10),
                        const Column(
                          children: [
                            Text("c²"),
                            Text("Speed of Light\nSquared", textAlign: TextAlign.center, style: TextStyle(fontSize: 11),),
                            Text(
                              "meters per second",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
