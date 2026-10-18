import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 主题定制①：种子色由默认 deepPurple 改为 teal（主色），
        // 同时定制标题字体样式（字重/字距），全应用通过 Theme.of 取用。
        colorScheme: .fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _step = 1; // 步长：每次点击 FAB 增加的值

  void _incrementCounter() {
    setState(() {
      _counter += _step;
    });
  }

  void _selectStep(int value) {
    setState(() => _step = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 主题取用①：从主题取 inversePrimary 作为 AppBar 背景色
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // 步长调节：弹层选择 1 / 2 / 5
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune),
            tooltip: '选择步长',
            onSelected: _selectStep,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 1, child: Text('步长 1')),
              PopupMenuItem(value: 2, child: Text('步长 2')),
              PopupMenuItem(value: 5, child: Text('步长 5')),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              // 主题取用②：从主题取 headlineMedium 文本样式
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              '步长：$_step',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
