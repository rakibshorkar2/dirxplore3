import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logic/proxy_manager.dart';

class ProxyTab extends ConsumerStatefulWidget {
  const ProxyTab({super.key});

  @override
  ConsumerState<ProxyTab> createState() => _ProxyTabState();
}

class _ProxyTabState extends ConsumerState<ProxyTab> {
  final _hostController = TextEditingController(text: '103.166.253.92');
  final _portController = TextEditingController(text: '1088');
  final _userController = TextEditingController(text: 'test');
  final _passController = TextEditingController(text: 'test');

  @override
  Widget build(BuildContext context) {
    final proxy = ref.watch(proxyManagerProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('SOCKS5 Proxy'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('PROXY CONFIGURATION'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _hostController,
                  prefix: const Text('Host'),
                  placeholder: 'Required',
                ),
                CupertinoTextFormFieldRow(
                  controller: _portController,
                  prefix: const Text('Port'),
                  placeholder: 'Required',
                  keyboardType: TextInputType.number,
                ),
                CupertinoTextFormFieldRow(
                  controller: _userController,
                  prefix: const Text('User'),
                  placeholder: 'Optional',
                ),
                CupertinoTextFormFieldRow(
                  controller: _passController,
                  prefix: const Text('Pass'),
                  placeholder: 'Optional',
                  obscureText: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('Save Configuration'),
              onPressed: () {
                final config = ProxyConfig(
                  host: _hostController.text,
                  port: int.tryParse(_portController.text) ?? 0,
                  username: _userController.text,
                  password: _passController.text,
                  enabled: proxy?.enabled ?? false,
                );
                ref.read(proxyManagerProvider.notifier).setProxy(config);
              },
            ),
            const SizedBox(height: 16),
            CupertinoListTile(
              title: const Text('Enable Proxy'),
              trailing: CupertinoSwitch(
                value: proxy?.enabled ?? false,
                onChanged: (val) {
                  ref.read(proxyManagerProvider.notifier).toggleProxy(val);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
