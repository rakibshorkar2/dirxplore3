import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../logic/proxy_manager.dart';

class ProxyTab extends ConsumerStatefulWidget {
  const ProxyTab({super.key});

  @override
  ConsumerState<ProxyTab> createState() => _ProxyTabState();
}

class _ProxyTabState extends ConsumerState<ProxyTab> {
  final _nameController = TextEditingController(text: 'SAMONLINE Proxy');
  final _hostController = TextEditingController(text: '103.166.253.92');
  final _portController = TextEditingController(text: '1088');
  final _userController = TextEditingController(text: 'test');
  final _passController = TextEditingController(text: 'test');

  @override
  Widget build(BuildContext context) {
    final proxies = ref.watch(proxyManagerProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('SOCKS5 Proxy'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _showAddProxySheet(context),
        ),
      ),
      child: SafeArea(
        child: proxies.isEmpty
            ? const Center(child: Text('No proxies added'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: proxies.length,
                itemBuilder: (context, index) {
                  final proxy = proxies[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground.resolveFrom(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(CupertinoIcons.shield_fill, color: CupertinoColors.activeBlue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(proxy.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${proxy.host}:${proxy.port}', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
                                ],
                              ),
                            ),
                            CupertinoSwitch(
                              value: proxy.enabled,
                              onChanged: (val) => ref.read(proxyManagerProvider.notifier).toggleProxy(proxy.id, val),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildStatusIndicator(proxy),
                                const SizedBox(width: 8),
                                Text(
                                  proxy.latency == null ? 'Not Tested' : (proxy.latency! < 0 ? 'Offline' : '${proxy.latency}ms'),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  minSize: 32,
                                  color: CupertinoColors.activeBlue.withAlpha(30),
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Text('Test', style: TextStyle(color: CupertinoColors.activeBlue, fontSize: 12)),
                                  onPressed: () => ref.read(proxyManagerProvider.notifier).testProxy(proxy.id),
                                ),
                                const SizedBox(width: 8),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed, size: 20),
                                  onPressed: () => ref.read(proxyManagerProvider.notifier).deleteProxy(proxy.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatusIndicator(ProxyConfig proxy) {
    Color color = CupertinoColors.systemGrey;
    if (proxy.latency != null) {
      color = proxy.latency! < 0 ? CupertinoColors.destructiveRed : CupertinoColors.activeGreen;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  void _showAddProxySheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add New Proxy'),
        message: Column(
          children: [
            CupertinoTextField(controller: _nameController, placeholder: 'Profile Name'),
            const SizedBox(height: 8),
            CupertinoTextField(controller: _hostController, placeholder: 'Host (IP)'),
            const SizedBox(height: 8),
            CupertinoTextField(controller: _portController, placeholder: 'Port', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CupertinoTextField(controller: _userController, placeholder: 'Username (Optional)'),
            const SizedBox(height: 8),
            CupertinoTextField(controller: _passController, placeholder: 'Password (Optional)', obscureText: true),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Save Proxy'),
            onPressed: () {
              final config = ProxyConfig(
                id: const Uuid().v4(),
                name: _nameController.text,
                host: _hostController.text,
                port: int.tryParse(_portController.text) ?? 0,
                username: _userController.text,
                password: _passController.text,
              );
              ref.read(proxyManagerProvider.notifier).addProxy(config);
              Navigator.pop(context);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
