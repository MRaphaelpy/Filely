import 'dart:io';

import 'package:filely/core/core.dart';
import 'package:filely/providers/providers.dart';
import 'package:filely/screens/apps_screen.dart';
import 'package:filely/screens/browse/recent_files.dart';
import 'package:filely/screens/category.dart';
import 'package:filely/screens/downloads.dart';
import 'package:filely/screens/images.dart';
import 'package:filely/screens/search.dart';
import 'package:filely/screens/whatsapp_status.dart';
import 'package:filely/utils/utils.dart';
import 'package:filely/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Browse extends StatefulWidget {
  @override
  _BrowseState createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStorage();
    });
  }

  Future<void> _refreshStorage() async {
    await Provider.of<CoreProvider>(context, listen: false).checkSpace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppStrings.appName,
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                context: context,
                delegate: Search(themeData: Theme.of(context)),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStorage,
        child: Consumer<CoreProvider>(
          builder: (context, provider, _) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                const SizedBox(height: 20.0),
                const _SectionTitle('Storage Devices'),
                _StorageSection(),
                CustomDivider(),
                const SizedBox(height: 20.0),
                const _SectionTitle('Categories'),
                _CategoriesSection(),
                CustomDivider(),
                const SizedBox(height: 20.0),
                const _SectionTitle('Recent Files'),
                RecentFiles(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
          color: Theme.of(context).colorScheme.secondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _StorageSection extends StatelessWidget {
  double _calculatePercent(int usedSpace, int totalSpace) {
    if (totalSpace <= 0) return 0.0;

    double percentage = usedSpace / totalSpace;

    return percentage.clamp(0.0, 1.0);
  }

  int _getValidStorageCount(CoreProvider coreProvider) {
    int count = 0;

    if (coreProvider.totalSpace > 0) {
      count++;
    }

    if (coreProvider.availableStorage.length > 1 &&
        coreProvider.totalSDSpace > 0) {
      count++;
    }

    return count;
  }

  List<Map<String, dynamic>> _getValidStorages(CoreProvider coreProvider) {
    List<Map<String, dynamic>> validStorages = [];

    if (coreProvider.availableStorage.isNotEmpty &&
        coreProvider.totalSpace > 0) {
      validStorages.add({
        'storage': coreProvider.availableStorage[0],
        'index': 0,
      });
    }

    if (coreProvider.availableStorage.length > 1 &&
        coreProvider.totalSDSpace > 0) {
      validStorages.add({
        'storage': coreProvider.availableStorage[1],
        'index': 1,
      });
    }

    return validStorages;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoreProvider>(
      builder: (BuildContext context, coreProvider, Widget? child) {
        if (coreProvider.storageLoading) {
          return SizedBox(height: 150, child: CustomLoader());
        }

        if (coreProvider.availableStorage.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Não foi possível carregar o armazenamento',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          );
        }

        debugPrint('Total Space: ${coreProvider.totalSpace}');
        debugPrint('Used Space: ${coreProvider.usedSpace}');
        debugPrint('Total SD Space: ${coreProvider.totalSDSpace}');
        debugPrint('Used SD Space: ${coreProvider.usedSDSpace}');

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _getValidStorageCount(coreProvider),
          itemBuilder: (BuildContext context, int index) {
            final validStorages = _getValidStorages(coreProvider);
            final FileSystemEntity item = validStorages[index]['storage'];
            final int storageIndex = validStorages[index]['index'];

            final String path = item.path.split('Android')[0];
            double percent;
            int usedSpace;
            int totalSpace;

            if (storageIndex == 0) {
              usedSpace = coreProvider.usedSpace;
              totalSpace = coreProvider.totalSpace;
            } else {
              usedSpace = coreProvider.usedSDSpace;
              totalSpace = coreProvider.totalSDSpace;
            }

            if (totalSpace <= 0) {
              debugPrint(
                'Aviso: Espaço total inválido para ${storageIndex == 0 ? "Device" : "SD Card"}: $totalSpace',
              );
              percent = 0.0;
            } else {
              percent = _calculatePercent(usedSpace, totalSpace);
              debugPrint(
                'Percentual de uso para ${storageIndex == 0 ? "Device" : "SD Card"}: $percent',
              );
            }
            return StorageItem(
              percent: percent,
              path: path,
              title: storageIndex == 0 ? 'Device Storage' : 'SD Card Storage',
              icon: storageIndex == 0 ? Icons.smartphone : Icons.sd_storage,
              color: storageIndex == 0 ? Colors.lightBlue : Colors.orange,
              usedSpace: usedSpace,
              totalSpace: totalSpace,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return CustomDivider();
          },
        );
      },
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Constants.categories.length,
      itemBuilder: (BuildContext context, int index) {
        final Map category = Constants.categories[index];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleCategoryTap(context, index, category),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: category['color'].withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      category['icon'],
                      size: 20,
                      color: category['color'],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${category['title']}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCategoryTap(BuildContext context, int index, Map category) {
    if (index == Constants.categories.length - 1) {
      if (Directory(FileUtils.waPath).existsSync()) {
        Navigate.pushPage(
          context,
          WhatsappStatus(title: '${category['title']}'),
        );
      } else {
        Dialogs.showToast('Please Install WhatsApp to use this feature');
      }
    } else if (index == 0) {
      Navigate.pushPage(context, Downloads(title: '${category['title']}'));
    } else if (index == 5) {
      Navigate.pushPage(context, AppScreen());
    } else {
      Navigate.pushPage(
        context,
        index == 1 || index == 2
            ? Images(title: '${category['title']}')
            : Category(title: '${category['title']}'),
      );
    }
  }
}
