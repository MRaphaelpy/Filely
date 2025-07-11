import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:filely/widgets/widgets.dart';

class AppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Installed Apps')),
      body: FutureBuilder<List<AppInfo>>(
        future: InstalledApps.getInstalledApps(true, true, ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomLoader();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os apps'));
          }

          if (snapshot.hasData) {
            List<AppInfo> data = snapshot.data!;
            data.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

            return ListView.separated(
              padding: EdgeInsets.only(left: 10),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                AppInfo app = data[index];
                return ListTile(
                  leading: app.icon != null
                      ? Image.memory(app.icon!, height: 40, width: 40)
                      : null,
                  title: Text(app.name),
                  subtitle: Text(app.packageName),
                  onTap: () => InstalledApps.startApp(app.packageName),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return CustomDivider();
              },
            );
          }

          return CustomLoader();
        },
      ),
    );
  }
}
